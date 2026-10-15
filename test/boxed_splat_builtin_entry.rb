# A splatted call on a boxed receiver, beside a user method of the same
# name, reaches the builtin with every argument the list holds.
class Reader
  def read(*a) = [:reader, a]
  def center(*a) = [:reader, a]
  def round(*a) = [:reader, a]
  def squeeze(*a) = [:reader, a]
  def tr(*a) = [:reader, a]
  def shift(*a) = [:reader, a]
  def take(*a) = [:reader, a]
end

def rd(o, *a) = o.read(*a)
def ce(o, *a) = o.center(*a)
def ro(o, *a) = o.round(*a)
def sq(o, *a) = o.squeeze(*a)
def sh(o, *a) = o.shift(*a)
def ta(o, *a) = o.take(*a)

r, w = IO.pipe
w.write("abcdef")
w.close
p rd([r, Reader.new][0], 2)
p rd([r, Reader.new][0])
p rd([Reader.new, r][0], 1, 2)

p ce(["ab", Reader.new][0], 6)
p ce(["ab", Reader.new][0], 6, "*")

p ro([3.7, Reader.new][0])
p ro([Reader.new, 3.7][0])

p sq(["aaabbbccc", Reader.new][0], "ab", "bc")
p sq([Reader.new, "aaabbbccc"][0], "ab", "bc")

p sh([[1, 2, 3], Reader.new][0], 2)
p sh([{ a: 1 }, Reader.new][0])
p ta([(1..9), Reader.new][0], 2)
p ta([[1, 2, 3], Reader.new][0], 1)

# a count the receiver's class does not take raises its own message
begin
  sh([{ a: 1 }, Reader.new][0], 1)
rescue ArgumentError => e
  p e.message
end
begin
  ce(["ab", Reader.new][0])
rescue ArgumentError => e
  p e.message
end

# a receiver whose class has no such method raises NoMethodError before
# an argument is read
class Loud
  def to_int
    puts "read"
    6
  end
end
begin
  ce([5, Reader.new][0], Loud.new)
rescue NoMethodError => e
  p e.name
end
