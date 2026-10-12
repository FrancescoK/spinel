# URI#+ is URI#merge: a String or a URI reference resolved against the
# receiver, and an absolute one returned as it is.
require "uri"
base = URI("http://example.com/a/b?q")
p (base + "c").to_s
p (base + URI("../d#f")).to_s
p (base + "https://other.example/x").to_s
p (base + "?z").to_s
p (URI("https://example.com") + "/p").class
