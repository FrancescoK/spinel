# spinel: share
# spinel: gc-minor
# The implicit message call keeps each override's own String identity.
class StoredError < StandardError
end
class FreshError < StandardError
  def to_s
    StoredError.new(+"inside").message
    +"fresh"
  end
end
class BorrowedError < StandardError
  def to_s = "frozen"
end
class SharedError < StandardError
  def initialize(s)
    @text = s
    super("other")
  end
  def to_s = @text
end
s = +"source"
e = SharedError.new(s)
t = e.message
t << "!"
p t.equal?(s), s, e.to_s
[FreshError.new, BorrowedError.new, StoredError.new(+"stored"), e].each do |err|
  begin
    raise err
  rescue => caught
    text = caught.message
  end
  begin
    text << "!"
  rescue FrozenError
    p :frozen
  end
  p text
end
p s
class InitializedError < StandardError
  def initialize(s) = super(s + "!")
end
def fresh_message(s) = FreshError.new(s).message
def fresh_raise(s)
  raise FreshError, s
rescue => e
  e.message
end
def initialized_message(s) = InitializedError.new(s).message
def initialized_raise(s)
  raise InitializedError, s
rescue InitializedError => e
  e.message
end
source = +"input"
a = fresh_message(source)
b = fresh_raise(source)
c = initialized_message(source)
d = initialized_raise(source)
a << "a"
b << "b"
c << "c"
d << "d"
p source, a, b, c, d

borrowed = BorrowedError.new
x = borrowed.message
y = borrowed.message
begin
  x << "!"
rescue FrozenError
end
p x.equal?(y), x.equal?("frozen"), x.frozen?

def absent_message(n)
  receiver = n == 0 ? nil : BorrowedError.new
  receiver.message
rescue NoMethodError
  +"missing"
end
missing = absent_message(ARGV.size)
missing << "!"
p missing

class ClonedError < StandardError
  def to_s = "frozen".clone
end
cloned = ClonedError.new
x = cloned.message
y = cloned.message
begin
  x << "!"
rescue FrozenError
end
p x.equal?(y), x.equal?("frozen"), x.frozen?
