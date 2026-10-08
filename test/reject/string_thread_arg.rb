# A String variable on this route must not silently lose its append.
# spinel: reject-share
# spinel: reject-thread-string
s = +"a"
Thread.new(s) { |t| t << "!" }.join
p s
