# `recv[k] += v` on a boxed receiver whose key is a Symbol or String: the
# key the statement evaluates once is boxed for the write.
class Counter
  def bump(k) = (@c ||= Hash.new(0))[k] += 1
  def drop(k) = (@c ||= Hash.new(0))[k] -= 2
  def c = @c
end
c = Counter.new
c.bump(:a); c.bump(:a); c.bump(:b)
p c.c

d = Counter.new
p d.bump("s")
p d.bump(:t)
p d.drop(:t)
p d.c

$g = nil
def gb(k)
  $g ||= Hash.new(0)
  $g[k] += 1
end
gb(:a); gb(:a); gb("b")
p $g
