# spinel: share
# A call that always answers nil, bound where a String is taken, still
# runs: its nil is what is bound, and its effects happen.
class Box
  def initialize = @items = ["a", "b", "c", "d", "e"]
  def clear!
    @items.pop
    nil
  end
  def size = @items.size
end

def check_nil(v)
  puts(v.nil? ? "nil" : "got #{v.inspect}")
end

b = Box.new
check_nil "x"
check_nil b.clear!
puts b.size

# an ivar that holds a String
@iv = "x"
@iv = b.clear!
p @iv
puts b.size

# a lambda's argument
pr = ->(s) { p s }
pr.call("q")
pr.call(b.clear!)
puts b.size

# a default of a parameter the method changes in place
def mut(box, s = box.clear!)
  t = s
  s << "!" if s
  p t
end
mut(b, +"m")
mut(b)
puts b.size

# Dir.glob's base:
Dir.glob("*.no-such-ext", base: b.clear!)
puts b.size
