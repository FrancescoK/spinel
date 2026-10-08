# The argument is read once, but the read runs on every pass of the loop,
# and each thread appends to a copy.
# spinel: reject-share
# spinel: reject-thread-string
s = +"a"
r = []
2.times { Thread.new(s) { |t| t << "!"; r << t.dup }.join }
p r
