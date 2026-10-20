# `k.label = v` on a Class value held in a local answers v, as any
# assignment does, whatever the writer's body answers: a method that
# ends with it returns v.
class Base
  @@log = []
  def self.label=(v)
    @@log << v
  end
  def self.log = @@log
  def set(v)
    k = self.class
    k.label = v
  end
  def set_n(n)
    k = self.class
    k.label = n * 2
  end
end
class Child < Base
  def self.label=(v)
    log << "child"
    log.size
  end
end
p Base.new.set("b"), Child.new.set("c")
p Base.new.set_n(3), Child.new.set_n(4)
k = [Base, Child][1]
x = (k.label = "y")
p x
$n = 0
def nxt = "v#{$n += 1}"
y = (k.label = nxt)
p y, $n
p Base.log
