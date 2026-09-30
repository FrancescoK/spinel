# A macro generates a class method that calls a macro writing the state: a call
# of the generated method outside the class body writes it where the compiler
# does not follow, so the macro reading the state in a later body is left as
# written (a run-time public_send, refused).
module Gen
  def gen_reset = module_eval("def self.reset(k) = kind(k)")
end
module Consts
  def kind(k)
    @kind = k
  end
  def constant(c)
    const_set(c, public_send(["calc", @kind, c.to_s.downcase].compact.join("_")))
  end
end
class Calc
  extend Gen
  extend Consts
  def self.calc_size = 1
  def self.calc_box_size = 2
  gen_reset
end
Calc.reset(:box)
class Calc
  constant :SIZE
end
p Calc::SIZE
