require 'pp'
require 'net/http'
require 'json'
require 'openssl'

NGROK_URL = 'http://xxxxxxxx.ngrok.io/'

event = {
  type: 'login_successful',
  uref: "user1234567",
  email: 'demo@demo.com',
  remote_ip: '216.58.204.110',
  callback_url: NGROK_URL,
  http_headers: {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2) AppleWebKit/537.74.9 (KHTML, like Gecko) Version/7.0.2 Safari/537.74.9",
  }
}

uri = URI.parse('https://events.inferenstar.com/')
req = Net::HTTP::Post.new(uri.path)
req['Content-Type'] = 'application/json; charset: utf-8'
req['X-API-Key'] = ENV['X_API_KEY']

req.body = event.to_json

http = Net::HTTP.new(uri.host, uri.port)
http.use_ssl = (uri.port == 443)

resp = http.request(req)

if resp.code != '202'
  puts resp.body
  raise "Invalid respond code: #{resp.code}"
else
  puts resp.body
end
