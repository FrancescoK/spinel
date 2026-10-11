# URI#merge and URI.join resolving references the way CRuby does: the
# RFC 3986 section 5.4 examples against its base, a reference given as a
# URI rather than a String, bases with no path or a non-default port, and
# the two errors. An absent query or fragment is nil and an empty one is
# "", so "?" clears the base's query where "#s" keeps it. Relative
# references parse as paths, so "c" and "../d" are not read as hosts, and
# "//host/x" is the one form that carries a host.
require "uri"

base = URI("http://a/b/c/d;p?q")
refs = ["g:h", "g", "./g", "g/", "/g", "//g", "?y", "g?y", "#s", "g#s",
        "g?y#s", ";x", "g;x", "g;x?y#s", "", ".", "./", "..", "../", "../g",
        "../..", "../../", "../../g", "../../../g", "../../../../g", "/./g",
        "/../g", "g.", ".g", "g..", "..g", "./../g", "./g/.", "g/./h",
        "g/../h", "g;x=1/./y", "g;x=1/../y", "g?y/./x", "g?y/../x",
        "g#s/./x", "g#s/../x", "http:g", "?", "g?", "#", "g#"]
refs.each { |r| puts "#{r.inspect} -> #{base.merge(r)}" }

u = URI.parse("http://127.0.0.1:8080/a/b")
puts u.merge("/")
puts u.merge(URI("../d?q=1"))
puts u.merge("c#frag")
puts u.merge("//[::1]:81/x")
puts URI("http:///x").merge("g")
p URI("http://a/b?q#f").merge("?").query
puts u.merge("//example.com:81")
puts URI("https://a").merge("b")
puts URI("https://a:8443/x/y").merge("//c/z").to_s
p URI("https://a/x").merge("//c").port
p u.merge("/").class
p u.to_s

%w[c ../d?q=1 //h:81/x /a#f ?q #f x? x# example.com/x a:/b
   http:///x http://h:/x].each do |s|
  r = URI.parse(s)
  p [s, r.to_s, r.absolute?, r.host, r.path, r.query, r.fragment]
end
p URI.parse("urn:isbn:1").opaque
p URI.parse("localhost:8080").opaque
p URI.parse("//h:81/x").host

p URI.join("http://example.com/a/", "b", "../c?x#y").to_s
p URI.join("http://example.com/a/b").to_s

begin
  URI("c").merge("d")
rescue URI::BadURIError => e
  p [e.class, e.message]
end
begin
  u.merge(1)
rescue ArgumentError => e
  p [e.class, e.message]
end
p URI("https://u@a:8443/x").merge("//c/z").to_s
p URI("https://u@a:8443/x").merge("//v@c:9/z").to_s
