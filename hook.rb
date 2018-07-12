
require "sinatra"

post '/' do
  request.body.rewind
  data = JSON.parse request.body.read

  # TODO: 署名を検証
  puts request.env["HTTP_X_HUB_SIGNATURE"]

  puts data["ref"]

  body "Hello World"
end

