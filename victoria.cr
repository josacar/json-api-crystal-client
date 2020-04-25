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

# https://crystal-lang.org/api/0.34.0/JSON.html#mapping(_properties_,strict=false)-macro
environments = Environments.from_json(environments).content.select do |env|
  env.branch == "production"
end

environments.each do |environment|
  runtime = environment.runtime
  stack = environment.stack

  fargate.add(stack) if runtime.includes?("fargate")
  beanstalk.add(stack) if runtime.includes?("beanstalk")
end

puts fargate.to_s
puts beanstalk.to_s
