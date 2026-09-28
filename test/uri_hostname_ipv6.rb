# URI#hostname answers an IPv6 host without its brackets, as CRuby does;
# #host keeps them.
require "uri"
u = URI.parse("http://[::1]/")
p u.host
p u.hostname
v = URI.parse("http://[2001:db8::7]:8080/a?b=1")
p [v.hostname, v.port]
p URI.parse("https://example.com/x").hostname
p URI.parse("http://127.0.0.1/").hostname
p URI::HTTP.build(host: "[::1]", path: "/").hostname
p URI::HTTP.build(path: "/").hostname
