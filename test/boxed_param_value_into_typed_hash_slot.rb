# A boxed parameter stored as a value into a typed hash held by an ivar,
# a class variable or a global
class K
  def initialize
    @h = {"a" => 1}
  end
  def put(v) = @h["b"] = v
  def h = @h
end
k = K.new
k.put(2)
k.put("z")
p k.h

class C
  @@h = {"a" => 1}
  def self.put(v) = @@h["b"] = v
  def self.h = @@h
end
C.put(1)
C.put(2.5)
p C.h

$g = {1 => "x"}
def gput(v) = $g[2] = v
gput("y")
gput(:z)
p $g

# a parameter every caller passes an Integer keeps the typed hash
class One
  def initialize
    @h = {"a" => 1}
  end
  def put(v) = @h["b"] = v
  def h = @h
end
o = One.new
o.put(2)
o.put(3)
p o.h
