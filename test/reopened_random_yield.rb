# A yielding builtin reopening calls its proc form with the caller's block.
# Random takes its runtime pointer as self; Array takes a boxed receiver.
def rc(v) = ($a = v)
class Random
  def m(a) = (rc([a]); yield)
  def pair(a) = [a, yield(a)]
  def maybe(a = 9) = block_given? ? yield(a) : a
end
class Array
  def m(a) = (rc([a]); yield)
  def pair(a) = [a, yield(a)]
  def maybe(a = 9) = block_given? ? yield(a) : a
end

r = Random.new(1)
a = [7]
p [r.m(1) { :blk }, $a]
p [a.m(2) { :blk }, $a]
blk = proc { :proc }
p [r.m(3, &blk), $a]
p [a.m(4, &blk), $a]
p r.pair(5) { |v| [v, :literal] }
p a.pair(6) { |v| [v, :literal] }
values = [8, 9]
handler = proc { |v| [v, values] }
p r.pair(7, &handler)
p a.pair(8, &handler)
p r.maybe, a.maybe
p r.maybe(10) { |v| v + 1 }
p a.maybe(11) { |v| v + 1 }
p r.maybe(12, &handler)
p a.maybe(13, &handler)

# Missing and explicitly nil blocks still raise at yield.
begin
  r.m(14)
rescue LocalJumpError
  p [:random_missing, $a]
end
begin
  a.m(15, &nil)
rescue LocalJumpError
  p [:array_missing, $a]
end

# A forwarding method passes its supplied block to the reopening.
def random_forward(r, &block) = r.maybe(16, &block)
def array_forward(a, &block) = a.maybe(17, &block)
p random_forward(r) { |v| [:forwarded, v] }
p array_forward(a) { |v| [:forwarded, v] }
