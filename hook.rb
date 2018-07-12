
require "sinatra"

SCRIPT_FILE = (ENV["SCRIPT_FILE"] || "test.sh").freeze
SCRIPT_DIR = 'scripts'.freeze

unless ENV["SCRIPT_PATH"].empty?
  SCRIPT_PATH = ENV["SCRIPT_PATH"]
else
  SCRIPT_PATH = File.expand_path("../#{SCRIPT_DIR}/#{SCRIPT_FILE}", __FILE__)
end

abort "SCRIPT_FILE not found" unless File.exist? SCRIPT_PATH

LOG_PATH = ENV["LOG_PATH"]

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

  spawn "#{SCRIPT_PATH}"

  body "script executed"
end

get '/' do
  body "alive"
end

get '/log' do
  unless File.exist? LOG_PATH
    halt 404, "Not found log file"
  end

  # tail したいので手抜き
  lines = `tail -n 100 #{LOG_PATH} | tac`.split("\n")
  body ["<ul>", *lines, "</ul>"].map { |line| "<li>#{line}</li>" }.join
end


def skip_script?(payload)
  commits = payload["commits"]
  return false if commits.empty?
  commits.any? do |commit|
    commit["message"].include? "[ci skip]"
  end
end

def html(body)
  """
  <!DOCTYPE html>
  <html lang=\"en\">
  <head>
    <meta charset=\"UTF-8\">
    <title></title>
  </head>
  <body>
    #{body}
  </body>
  </html>
  """
end
