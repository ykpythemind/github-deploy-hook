
require "sinatra"

sha1 = "sha1=41089c213457a147289e4b06f5cbb5cd7cc13680"

post '/' do
  if request.env["HTTP_X_GITHUB_EVENT"] != "push"
    halt 200, "Event is not push"
  end

  # TODO: 署名を検証
  puts request.env["HTTP_X_HUB_SIGNATURE"]

  # FIXME
  if request.env["HTTP_X_HUB_SIGNATURE"] != sha1
    halt 401
  end

  request.body.rewind
  data = JSON.parse request.body.read

  if data["ref"] != "refs/heads/master"
    halt 200, "Not master branch"
  end

  body "Hello World"
end

