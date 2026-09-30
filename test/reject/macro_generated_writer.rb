# A class method a macro defines from a lambda, writing the state, called
# outside the class body: a later macro reading the state is left as written
# (a run-time public_send, refused), not expanded with the state unchanged.
module Setters
  def setter(n) = define_singleton_method(n, -> { @kind = :box })
end
module Consts
  def constant(c)
    const_set(c, public_send(["calc", @kind, c.to_s.downcase].compact.join("_")))
  end
end
class Calc
  extend Setters
  extend Consts
  def self.calc_size = 1
  def self.calc_box_size = 2
  setter :set_kind
end
Calc.set_kind
class Calc
  constant :SIZE
end
p Calc::SIZE
