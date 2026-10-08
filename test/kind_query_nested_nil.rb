# A kind query nested in another's class argument still answers for a nil
# receiver: the outer query's live arm re-entered the call with nil's test
# switched off for every call inside it, so `inner.is_a?(Animal)` on a nil
# `inner` answered for an Animal there. A class argument that runs code
# runs once, before the outer receiver's test.
# spinel: gc-minor
class Animal; end
class Dog < Animal; end
class Cat; end
def pick(i) = i == 0 ? nil : Dog.new
def kls(i) = i == 0 ? Animal : Object
def make_inner
  puts "make_inner"
  garbage = Array.new(20) { +"garbage" }
  pick(0)
end

inner = pick(0)
outer = pick(1)
k = kls(0)
p outer.is_a?(inner.is_a?(Animal) ? Animal : Cat)
p outer.is_a?(inner.kind_of?(NilClass) ? Animal : Cat)
p outer.is_a?(inner.instance_of?(NilClass) ? Animal : Cat)
p outer.is_a?(inner.is_a?(k) ? Animal : Cat)
p outer.instance_of?(inner.is_a?(Object) ? Dog : Cat)
p outer.is_a?(outer.is_a?(Animal) ? Dog : Cat)
p inner.is_a?(inner.is_a?(Animal) ? Animal : NilClass)
p outer.is_a?(make_inner.is_a?(Animal) ? Animal : Cat)
p inner.is_a?(make_inner.is_a?(Animal) ? Animal : NilClass)
p inner.instance_of?(kls(make_inner.nil? ? 1 : 0))
