# `require "net/https"` loads net/http and openssl, as faraday-net_http asks
# for them: Net::HTTP, its timeouts and the OpenSSL verify constants all resolve.
require "net/https"

p Net::HTTP
p Net::OpenTimeout.ancestors.include?(Timeout::Error)
p OpenSSL::SSL::VERIFY_PEER
p OpenSSL::SSL::SSLError.ancestors.include?(StandardError)
http = Net::HTTP.new("example.com", 443)
http.use_ssl = true
p http.use_ssl?
