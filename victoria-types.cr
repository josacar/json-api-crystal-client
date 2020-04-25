require "http/client"
require "json"

url = "https://victoriatradehouse-api.lolware.com/query/environments?includeProtected=true&size=8000"
response = HTTP::Client.get(url)
environments = response.body

class EnvironmentSet(T)
  def initialize(@name : String)
    @apps = [] of T
  end

  def add(item : T)
    @apps << item
  end

  def count
    @apps.size
  end

  def to_s
    pretty_apps = @apps.map { |x| "- #{x}" }.join("\n")
    "#{@name}: #{count}\n#{pretty_apps}"
  end
end

fargate = EnvironmentSet(String).new("fargate")
beanstalk = EnvironmentSet(String).new("beanstalk")

# alias JSON::Any::Type = Array(JSON::Any) | Bool | Float64 | Hash(String, JSON::Any) | Int64 | String | Nil
json_data = JSON.parse(environments)

begin
  environments = json_data["content"].as_a.select do |env|
    env["branch"].as_s == "production"
  end

  environments.each do |environment|
    runtime = environment["runtime"].as_s
    stack = environment["stack"].as_s

    fargate.add(stack) if runtime.includes?("fargate")
    beanstalk.add(stack) if runtime.includes?("beanstalk")
  end
rescue error : TypeCastError
  puts "Error parsing: #{error}"
end

puts fargate.to_s
puts beanstalk.to_s

