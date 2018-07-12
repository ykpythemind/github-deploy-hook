
require "sinatra"

DEPLOY_SCRIPT_FILE = ENV["DEPLOY_SCRIPT_FILE"] || "test.sh"
DEPLOY_SCRIPT_DIR = 'scripts'
DEPLOY_SCRIPT_PATH = File.expand_path("../#{DEPLOY_SCRIPT_DIR}/#{DEPLOY_SCRIPT_FILE}", __FILE__)

abort "DEPLOY_SCRIPT_FILE not found" unless File.exist? DEPLOY_SCRIPT_PATH

post '/' do
  if request.env["HTTP_X_GITHUB_EVENT"] != "push"
    halt 200, "Event is not push"
  end

  # TODO: 署名を検証
  puts request.env["HTTP_X_HUB_SIGNATURE"]

  request.body.rewind
  data = JSON.parse request.body.read

  if data["ref"] != "refs/heads/master"
    halt 200, "Not master branch"
  end

  result = `#{DEPLOY_SCRIPT_PATH}`
  result += "\nexitstatus: #{$?.exitstatus}"

  puts result
  body result
end

