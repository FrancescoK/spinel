# run-scale: 10000 | 160000 | 24
# Appending to one String grows its buffer geometrically: the bytes grow
# with the length (16x), not with its square.
s = +""
ARGV[0].to_i.times { |i| s << (i % 10).to_s }
p s.bytesize
