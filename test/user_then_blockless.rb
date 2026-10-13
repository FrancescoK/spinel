# a class's own then / yield_self, called without a block, is the method
# called: the builtin's blockless form, an Enumerator of the receiver, is
# what any other value answers, a boxed one included

class ThenOwner
  def then = "own then"
  def yield_self = 7
end
class Plain; end

p ThenOwner.new.then
p ThenOwner.new.yield_self
p ThenOwner.new.then { |x| 1 }
p 5.then.to_a
p Plain.new.then.class
[ThenOwner.new, 3].each { |x| p x.then.class }
