# `class A::Calc` inside a namespace looks A up from there: it reopens
# ::A::Calc, so the macro reading that class's state is left as written.
module Consts
  def kind(k = nil)
    return @kind if k.nil?
    @kind = k
  end
  def constant(c)
    const_set(c, public_send(["calc", kind, c.to_s.downcase].join("_")))
  end
end
module A
  class Calc
    extend Consts
    def self.calc_a_size = 1
    def self.calc_b_size = 2
    kind :a
  end
  module B
    class A::Calc
      kind :b
    end
  end
  class Calc
    constant :SIZE
  end
end
p A::Calc::SIZE
