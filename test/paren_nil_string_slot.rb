# A sequence in parentheses whose value is nil, `(n += 1; nil)` or `()`,
# written into a local or a class variable that later holds a String
# changed in place through another name, is that variable's nil, as `nil`
# is, and the statements before the nil run.
class Box
  def put(s)
  end
end

n = 0
u = (n += 1; nil)
p u
Box.new.put(u = +"box")
u << "~"
p u

v = ()
p v
Box.new.put(v = +"pail")
v << "!"
p v

class C
  @@u = (1; nil)
  def self.set = @@u = +"x"
  def self.u = @@u
end
p C.u
C.set
t = C.u
t << "!"
p C.u

class D
  @@w = ()
  def self.set = @@w = +"y"
  def self.w = @@w
  def self.app(s) = s << "?"
end
D.set
D.app(D.w)
p D.w, n
