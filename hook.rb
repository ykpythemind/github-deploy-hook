
require "sinatra"

SCRIPT_FILE = (ENV["SCRIPT_FILE"] || "test.sh").freeze
SCRIPT_DIR = 'scripts'.freeze
SCRIPT_PATH = File.expand_path("../#{SCRIPT_DIR}/#{SCRIPT_FILE}", __FILE__)

abort "SCRIPT_FILE not found" unless File.exist? SCRIPT_PATH

post '/' do
  if request.env["HTTP_X_GITHUB_EVENT"] != "push"
    halt 200, "Event is not push"
  end

  # TODO: 署名を検証
  puts request.env["HTTP_X_HUB_SIGNATURE"]

  request.body.rewind
  payload = JSON.parse request.body.read

  if payload["ref"] != "refs/heads/master"
    halt 200, "Not master branch"
  end

  if skip_script?(payload)
    halt 200, "Skipped."
  end

  result = `#{SCRIPT_PATH}`
  result += "\nexitstatus: #{$?.exitstatus}"

  puts result
  body result
end

get '/' do
  body "alive"
end

def skip_script?(payload)
  commits = payload["commits"]
  return false if commits.empty?
  commits.any? do |commit|
    commit["message"].include? "[ci skip]"
  end
end
