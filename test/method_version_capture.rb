# spinel: gc-minor
# Method lookup observes redefinitions at call or capture time.
class D
  def speak = "d"
end
def capture(d) = d.method(:speak)
def retain(&b) = b
def capture_block(d) = retain(&d.method(:speak))
d = D.new
before = capture(d)
block_before = capture_block(d)
class D
  def speak = "d2"
end
after = capture(d)
block_after = capture_block(d)
p before.call, after.call
p block_before.call, block_after.call
