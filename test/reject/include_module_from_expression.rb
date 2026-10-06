# `include` of a module the program names by an expression, not a constant:
# the mixin is resolved at compile time, so it is refused rather than
# silently leaving the module's methods out.
module Registry
  def reg = :yes
end
def pick(m) = m
class D
  include pick(Registry)
end
p D.new.reg
