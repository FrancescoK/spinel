require "uri"

# URI::RFC2396_PARSER.make_regexp, as Rack::Lint uses it
abs = /\A#{URI::RFC2396_PARSER.make_regexp}\z/
["http://example.com/a?b=1#f", "https://user@[::1]:8080/x", "mailto:a@b.c",
 "/path", "*", "example.com:443", "http://a b", ""].each do |s|
  p [s, abs.match?(s)]
end
m = URI::RFC2396_PARSER.make_regexp.match("http://u@h.example:81/p/q;x?k=v#top")
p m.captures
http = URI::RFC2396_PARSER.make_regexp(["http", "https"])
p http.match?("HTTPS://x"), http.match?("ftp://x")
p URI::RFC2396_PARSER.make_regexp.source == URI::RFC2396_PARSER.make_regexp.source
