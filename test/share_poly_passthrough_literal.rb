# A boxed receiver's call whose every possible target answers a String
# literal, one of them through a method that hands on its argument
# (`def zork(src) = src` given "lit"): the literal is the answer, which a
# method that changes what it is handed leaves alone, being frozen. The
# dispatch counted the pass-through method of a class the receiver never
# holds as an arm, and the call was refused (#9258). Where the argument
# handed through is the caller's own String, it is that String.

def keep(t) = (t << "!" unless t.frozen?; t)

class I
  def zork(src) = src
end

class K
  def zork(src) = I.new.zork("lit")
end

class J
  def zork(src) = I.new.zork(src)
end

s = +"gif"
[K.new, K.new].each { |v| p keep(v.zork(s)) }
p s

u = +"own"
[J.new, J.new].each { |v| p keep(v.zork(u)) }
p u

x = +"x"
[K.new, I.new].each { |v| p keep(v.zork(x)) }
p x
