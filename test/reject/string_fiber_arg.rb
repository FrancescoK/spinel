# A String variable on this route must not silently lose its append.
# spinel: reject-share
# spinel: reject-thread-string
s = +"a"
f = Fiber.new { |t| t << "!" }
f.resume(s)
p s
