require 'net/http'
require 'json'

url = 'https://victoriatradehouse-api.lolware.com/query/environments?includeProtected=true&size=8000'
uri = URI(url)
response = Net::HTTP.get(uri)
environments = JSON.parse(response)

prod_environments = environments['content'].select do |env|
  env['branch'] == 'production'
end

prod = prod_environments.each_with_object({}) do |item, memo|
  memo['fargate_envs'] ||= []
  memo['beanstalk_envs'] ||= []
  memo['fargate'] ||= 0
  memo['beanstalk'] ||= 0

  if item['runtime'].include?('fargate')
    memo['fargate'] += 1
    memo['fargate_envs'] << item['stack']
  end

  if item['runtime'].include?('beanstalk')
    memo['beanstalk'] += 1
    memo['beanstalk_envs'] << item['stack']
  end
end

puts prod
