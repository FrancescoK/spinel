# Array.new(n, &blk) runs the passed block for each index, as a literal block
# does; it came out empty.
def build(n, &b) = Array.new(n, &b)
p build(3) { |i| i * 2 }
sq = proc { |i| i * i }
p Array.new(4, &sq)
lm = ->(i) { "x#{i}" }
p Array.new(2, &lm)
p Array.new(3, &:to_s)
