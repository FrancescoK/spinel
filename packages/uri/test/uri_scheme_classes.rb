# The scheme classes URI.parse answers and the URI helpers around them,
# diffed against CRuby: FTP, File, WS, WSS and MailTo, each with its default
# port; user/password, normalize, relative?, inspect; URI::Generic.build;
# URI.split; encode_uri_component / decode_uri_component; DEFAULT_PARSER.
require "uri"

["http://x.com/a", "https://x.com", "ftp://u:p@x.com/a/b;type=i", "file:///etc/hosts",
 "ws://x.com/chat", "wss://x.com:8443/chat", "mailto:a@b.c?subject=hi&body=x",
 "foo://x.com/y", "urn:isbn:1", "/a?q", "//h/p"].each do |s|
  u = URI.parse(s)
  p [u.class, u.scheme, u.host, u.port, u.path, u.opaque, u.query, u.to_s]
end

f = URI("ftp://u:p@x.com/a/b;type=i")
p [f.path, f.typecode, f.user, f.password, f.to_s]
p URI("ftp://x.com:2121/pub").to_s
p [URI("ftp://x").to_s, URI("ftp://x/%2Fetc").path, URI("ftp://x/%2Fetc").to_s, URI("ftp://x/a?b").to_s]
af = URI("ftp://x/a")
af.path = "/abs"
p af.to_s
p [URI("ftp://x.com").default_port, URI("http://x.com").default_port, URI("foo://x").default_port]
p [URI::HTTP.default_port, URI::HTTPS.default_port, URI::FTP.default_port, URI::WS.default_port,
   URI::WSS.default_port, URI::File.default_port, URI::MailTo.default_port, URI::Generic.default_port]
p [URI("http://x:/").port, URI("foo://x").port, URI("foo:bar").port, URI("foo:bar").path]

m = URI("mailto:a@b.c?subject=hi&body=x")
p [m.to, m.headers, m.opaque, m.path, m.host]
p [URI("mailto:?subject=a").to, URI("mailto:a@b?x").headers, URI("mailto:a@b,c@d").to]
begin
  URI("mailto:x")
rescue URI::InvalidComponentError => e
  p [e.class, e.message]
end

p [URI("http://u:pw@x").user, URI("http://u:pw@x").password, URI("http://u@x").password, URI("http://x").user]
p [URI("HTTP://X.COM").normalize.to_s, URI("http://X.com/A?B").normalize.to_s, URI("foo://X").normalize.to_s,
   URI("mailto:A@B").normalize.to_s]
p [URI("/a").relative?, URI("http://x").relative?, URI("/a").scheme]
p URI("http://x.com/a")
p URI("mailto:a@b")

g = URI::Generic.build(scheme: "foo", host: "x.com", path: "/y", query: "q")
p [g.class, g.to_s, g.port]
p [URI::HTTP.build(host: "x").port, URI::HTTP.build(host: "x").to_s]

p URI.split("http://u@x:1/a?q#f")
p URI.split("mailto:a@b")
p URI.split("/a?q")
p URI.split("http://x:/")

p URI.encode_uri_component("a b+c/é*~")
p URI.decode_uri_component("a+b%20c%C3%A9")
begin
  URI.decode_uri_component("a+%zz")
rescue ArgumentError => e
  p e.message
end

pa = URI::DEFAULT_PARSER
p [pa.class, pa.equal?(URI::RFC3986_PARSER)]
p pa.escape("a b/é?#%[]")
p pa.escape("a b", / /)
p pa.unescape("a%20b+%2Fc%zz%C3%A9")
p pa.split("http://x/a")
p pa.parse("ftp://x/y").class
p pa.join("http://x/a/", "b").to_s

# An explicit port 0 is a port, not an absent one.
p [URI("http://x:0/").port, URI("http://x:0/").to_s, URI("http://a/b").merge("//c:0/d").to_s]
