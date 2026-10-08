# A class's own == is not run on the nil of a slot: nil answers as nil does,
# equal to nil alone, and the method runs for an object.
class Tag
  attr_reader :v
  def initialize(v) = @v = v
  def ==(o) = o.is_a?(Tag) && @v == o.v
end

def mk(n) = (puts "mk #{n}"; Tag.new(n))
def pick(n) = n > 0 ? Tag.new(n) : nil

# a gap an Array's store past the end leaves
a = [Tag.new(1)]
a[2] = Tag.new(4)
p a[1] == nil
p a[1] != nil
p nil == a[1]
p nil != a[1]
p a[1] == Tag.new(1)
p a[1] != Tag.new(1)
p a[1] == a[1]
p a[1] == a[0]
p a[0] == a[1]
p a[1] == 1
p a[0] == nil
p a[0] == Tag.new(1)
p a[2] != Tag.new(4)

# the argument runs once, after the receiver, whatever the receiver holds
p a[1] == mk(1)
p a[0] == mk(1)
p(ARGV.size == 5 && a[1] == mk(2))

# a method's nil, in a condition and in a loop
puts(pick(0) == nil ? "nil" : "object")
puts "object" unless pick(3) == nil
i = 0
i += 1 while i < 3 && !(pick(i) == Tag.new(2))
p i

# a boxed argument
q = [1, Tag.new(1), nil]
p a[1] == q[2]
p a[1] == q[1]
p a[0] == q[1]
p a[1] != q[2]

# === is ==, in a `when` too
p a[1] === nil
case nil
when a[1] then puts "the gap"
else puts "no match"
end

# an instance variable nothing has set yet, and a parameter given nil
class Holder
  def fill = @k = Tag.new(1)
  def same?(o) = @k == o
  def unset? = @k == nil
end
h = Holder.new
p h.unset?
p h.same?(Tag.new(1))
h.fill
p h.unset?
p h.same?(Tag.new(1))

def nil_arg?(x) = x == nil
p nil_arg?(nil)
p nil_arg?(Tag.new(1))
