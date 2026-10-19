# A reflective read of a String ivar (`obj.instance_variable_get(:@name)`)
# answers the ivar's String itself, as an attribute reader does. Boxed, as
# the tail of the block a String reopening's yielding method hands back, as
# the value a block answers, as an Array's or a Hash's element, it took the
# String's bytes into a box of their own, so a change through the box never
# reached the ivar's String (and an Array element or a block's value did
# not compile).
class String
  def pm(a) = yield(a)
end
class Box
  def initialize(n)
    @name = n
  end
  def name = @name
end
s = +"hello"
bx = Box.new(s)

r = "x".pm(s) { |v| bx.instance_variable_get(:@name) }
r << "Z"
p bx.name, s, r.equal?(s)

r2 = "x".pm(s) { |v| next bx.instance_variable_get("@name") if v.size > 1; v }
r2 << "Y"
p bx.name, r2.equal?(s)

r3 = [1].map { |i| bx.instance_variable_get(:@name) }.first
r3 << "X"
p bx.name, r3.equal?(s)

r4 = [bx.instance_variable_get(:@name)][0]
r4 << "W"
p bx.name, r4.equal?(s)

r5 = { k: bx.instance_variable_get(:@name) }[:k]
r5 << "V"
p bx.name, r5.equal?(s)

def ident(x) = x

r6 = ident(bx.instance_variable_get(:@name))
r6 << "U"
p bx.name, r6.equal?(s)

def ret(o) = o.instance_variable_get(:@name)

r7 = ret(bx)
r7 << "T"
p bx.name, r7.equal?(s)

r8 = ARGV.size > 5 ? +"other" : bx.instance_variable_get(:@name)
r8 << "S"
p bx.name, r8.equal?(s)

# an identity test against a boxed value, and a method's tail
z = [s, 1][ARGV.size]
p z.equal?(bx.instance_variable_get(:@name)), bx.instance_variable_get(:@name).equal?(z)

def tail_of(o)
  o.instance_variable_get(:@name)
end

r9 = tail_of(bx)
r9 << "R"
p bx.name, r9.equal?(s)
