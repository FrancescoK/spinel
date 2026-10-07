# URI::RFC2396_Parser#pattern, the regexp sources a server builds its own
# matchers from (webrick matches a Host header with the :HOST one), and
# #absolute?, which tells a request target's full URL from a bare path.
require "uri"
pat = URI::RFC2396_Parser.new.pattern
%i[ESCAPED UNRESERVED RESERVED DOMLABEL TOPLABEL HOSTNAME URIC URIC_NO_SLASH
   QUERY FRAGMENT IPV4ADDR IPV6ADDR IPV6REF HOST PORT HOSTPORT USERINFO].each do |k|
  puts "#{k}: #{pat.fetch(k)}"
end
host = /\A(#{pat.fetch(:HOST)})(?::(\d+))?\z/n
p "localhost:8080".scan(host)[0]
p "127.0.0.1".scan(host)[0]
p "[::1]:3000".scan(host)[0]
p "bad host".scan(host)[0]
p URI("/hello").absolute?
p URI("http://example.com/hello").absolute?
