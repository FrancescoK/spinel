# spinel: reject-super-value
# `super` in a rescue modifier that is not a statement of its own, here
# (super rescue nil), in an initialize. The modifier is emitted as a
# conditional expression whose operand is the void call of initialize, which
# does not compile, so the value of such a `super` is refused as a used one;
# the bare `super rescue nil` as the last statement is a statement, and
# compiles (test/super_initialize_tail_rescue_mod.rb).
class Base
  attr_reader :log
  def initialize(x)
    @log = ["base #{x}"]
  end
end

class Sub < Base
  def initialize(x)
    (super rescue nil)
  end
end

p Sub.new(2).log
