require 'sinatra'
require 'pp'
require 'json'

post '/' do
  data = JSON.parse(request.body.read)
  puts JSON.pretty_generate(data)
end

