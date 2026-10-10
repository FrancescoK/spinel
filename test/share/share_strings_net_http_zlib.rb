# Both bundled packages loaded at once (#8266). zlib's GzipReader#read is a
# user method a boxed receiver can reach beside an IO's read, so net/http's
# `@tls.read(n)` reaches it; its answers stay new Strings, and so do
# wire_read's (a conditional over an IO's read and that boxed read), which
# `chunk = wire_read(size)` and `body = if ... end` take.
require "net/http"
require "zlib"
puts "ok"
