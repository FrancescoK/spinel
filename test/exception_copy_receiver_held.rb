# Exception#exception(msg) on a receiver whose own evaluation allocates: the
# copy carries the message it was given, and the receiver's fields.

def churn
  keep = []
  50000.times { |i| keep << "y" + i.to_s }
  keep.length
end

def build
  churn
  RuntimeError.new("first")
end

x = build.exception("again")
puts x.message
puts x.class

# a frozen String that is no literal, one with a NUL, an empty one
LABEL = ("ag" + "ain").freeze
puts build.exception(LABEL).message
p build.exception("left\0right").message
p build.exception("").message

# a copy of a copy
e = RuntimeError.new("first")
y = e.exception("one").exception("again")
churn
puts y.message
puts e.message

# many, kept: each has the message it was given
kept = []
300.times { |i| kept << e.exception("one").exception("again") }
puts kept.count { |k| k.message == "again" }

# a class of the program keeps what it holds
class Coded < StandardError
  def initialize(msg = "coded")
    super(msg)
    @code = [7, "seven"]
  end

  def code
    @code
  end
end

def coded
  churn
  Coded.new("first")
end

z = coded.exception("again")
puts z.message
p z.code
puts z.class

# the receiver is the value of a conditional, a block, a begin
w = (churn > 0 ? build : nil).exception("again")
puts w.message
v = [1].map { build.exception("again") }.first
puts v.message
u = begin
  build
end.exception("again")
puts u.message

# raised with a message: the copy is what is rescued
begin
  raise build.exception("again")
rescue => r
  puts r.message
end
