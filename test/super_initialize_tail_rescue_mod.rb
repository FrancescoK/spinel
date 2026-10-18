# `super` in a rescue modifier that is the last statement of an initialize.
# initialize is compiled to return nothing, so a `super` whose value is used
# is refused; here the value of the modifier is the value of initialize,
# which `new` drops. The modifier was not looked through, so the value was
# taken for a used one and the program was refused.
class Base
  attr_reader :log
  def initialize(x)
    raise ArgumentError, "negative" if x < 0
    @log = ["base #{x}"]
  end
end

class Quiet < Base
  def initialize(x)
    super rescue nil
  end
end

class Loud < Base
  def initialize(x)
    nil.foo rescue super
  end
end

p Quiet.new(2).log
p Quiet.new(-1).log
p Loud.new(4).log
