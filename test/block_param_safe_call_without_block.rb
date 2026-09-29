def f(&blk) = blk&.call
p f
p f { 3 }
def g(x, &blk)
  blk&.call(x)
  r = blk&.call(x + 1)
  p r
  blk&.(x)
end
p g(1)
p g(2) { |v| v * 10 }
def h(&b) = g(5, &b)
p h
p h { |v| v.to_s }
def k(&b)
  s = b&.call("a")
  s ? s + "!" : "none"
end
p k
p k { |x| x * 2 }
def fl(&b) = b&.call(1.5)
p fl
p fl { |x| x * 2 }
def st(&b) = b&.call
p st
p st { "s" }
