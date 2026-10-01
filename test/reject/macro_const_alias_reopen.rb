# A class body under a constant that aliases the class reopens it: its macro
# calls write that class's state, so the macro reading it is left as written.
module Consts
  def kind(k = nil)
    return @kind if k.nil?
    @kind = k
  end
  def constant(c)
    const_set(c, public_send(["calc", kind, c.to_s.downcase].join("_")))
  end
end
class Calc
  extend Consts
  def self.calc_a_size = 1
  def self.calc_b_size = 2
  kind :a
end
Alias = Calc
class Alias
  kind :b
end
class Calc
  constant :SIZE
end
p Calc::SIZE
