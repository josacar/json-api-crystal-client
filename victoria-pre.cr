require "http/client"
require "json"

url = "https://victoriatradehouse-api.lolware.com/query/environments?includeProtected=true&size=8000"
response = HTTP::Client.get(url)
environments = response.body

class Environment
  JSON.mapping(
    branch: String,
    runtime: String,
    stack: String
  )
end

class Environments
  JSON.mapping(
    content: Array(Environment)
  )
end

alias ResultHash = Hash(String, (Array(String) | Int32))

prod = Environments.from_json(environments).content.select do |env|
  env.branch == "production"
end.each_with_object(ResultHash.new) do |item, memo|
  memo["fargate_envs"] ||= [] of String
  memo["beanstalk_envs"] ||= [] of String
  memo["fargate"] ||= 0
  memo["beanstalk"] ||= 0

  if item.runtime.includes?("fargate")
    fargate_envs = memo["fargate"].as(Int32)
    fargate_envs += 1
    memo["fargate"] = fargate_envs
    memo["fargate_envs"].as(Array) << item.stack
  end

  if item.runtime.includes?("beanstalk")
    beanstalk_envs = memo["beanstalk"]
    beanstalk_envs += 1 if beanstalk_envs.is_a?(Int32)
    memo["beanstalk"] = beanstalk_envs
    memo["beanstalk_envs"].as(Array) << item.stack
  end
end

puts prod
