# URI::HTTP(S)#origin and #authority, diffed against CRuby: the default
# port is left off and any other kept, userinfo, path, query and fragment
# are dropped, and a URI.join result answers the origin of what it
# resolved to (what a CSP builder compares against request.base_url).
require "uri"
p URI("http://example.com/a?b=1#c").origin
p URI("https://user:pw@example.com:443/x").origin
p URI("https://example.com:8443/x").origin
p URI("http://localhost:3000").origin
p URI("http://localhost:3000").authority
p URI("https://example.com/").authority
u = URI.join("http://www.example.com", "/assets/application.js")
p u.origin
p u.origin == "http://www.example.com"
p URI.join("https://cdn.example.com:8080/x/", "y.js").origin
