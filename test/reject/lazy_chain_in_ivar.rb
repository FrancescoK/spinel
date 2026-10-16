# spinel: reject-lazy: a lazy chain held in an instance, class or global variable or a constant
# A lazy chain stored in an instance variable has no value at run time: it is
# fused into the call that forces it, and only a local or a method answering
# it is spliced there. It compiled and raised "undefined method 'lazy' for an
# instance of Array" at run time (#9160); refused at compile time instead.
class Gadget
  def initialize
    @lazy = [1, 2, 3].lazy
  end

  def all
    @lazy.to_a
  end
end

p Gadget.new.all
