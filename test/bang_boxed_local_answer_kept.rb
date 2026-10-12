# A String bang on a variable that holds its String boxed answers that
# String when it changed something, so a name the answer reaches (a local,
# a parameter, a block's parameter) is another name for the variable's
# String, and an append through it is seen through the variable, as in
# CRuby. Under --share-strings the box held the plain String, the bang
# answered a box of the new bytes, and each name took a handle of its own:
# the append landed in a copy.
def m(x) = x << "!"
def m_nil(x) = (x << "!" if x)
def y(s) = yield(s)

def run
  s = [+"ab", 1].first
  m(s.upcase!)
  p s
  t = s.downcase!
  t << "?" if t
  p s
end
run

# a local written from the bang, parenthesized, and compared
s = [+"ab", 1].first
t = s.upcase!
t << "!"
p s, t.equal?(s)
s = [+"cd", 1].first
t = (s.upcase!)
t << "!"
p s

# an argument the callee yields to a block that appends
s = [+"ef", 1].first
y(s.upcase!) { |x| x << "!" }
p s

# a nil answer, then a changing one
s = [+"GH", 1].first
m_nil(s.upcase!)
p s
t = s.downcase!
t << "?" if t
p s

# bangs with arguments and the self-answering succ!/next!
s = [+"a  b", 1].first
t = s.squeeze!
t << "|"
t = s.swapcase!
t << "?"
p s
s = [+"az", 1].first
t = s.next!
t << "!"
u = s.succ!
p s, u.equal?(s)

# an instance variable, and a method's value
class H
  def initialize = @s = [+"ij", 1].first
  def go = (t = @s.upcase!; t << "!")
  def down = @s.downcase!
  def s = @s
end
h = H.new
h.go
p h.s
t = h.down
t << "?"
p h.s

# in a loop, in a proc and a lambda, with a binary String
s = [+"kl", 1].first
i = 0
while i < 3
  t = s.upcase!
  t = s.downcase! unless t
  t << i.to_s
  i += 1
end
p s
s = [+"mn", 1].first
pr = proc { t = s.upcase!; t << "!" }
pr.call
l = -> { s.downcase! }
v = l.call
v << "?"
p s
s = [+"o\0p", 1].first
t = s.upcase!
t << "!"
p s, s.bytesize

# a receiver that is no String raises as CRuby does
def pick(i) = [+"qr", 2, 3.0, nil][i]
[0, 1, 2, 3].each do |i|
  s = pick(i)
  begin
    t = s.upcase!
    t << "!" if t
    p s
  rescue NoMethodError => e
    puts e.class
  end
end
s = ["st".freeze, 1].first
begin
  t = s.upcase!
  t << "!"
rescue FrozenError => e
  puts e.class
end
p s
