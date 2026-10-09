# Annotations inside a `Name = Class.new do ... end` body belong to Name.
Counter = Class.new do
  def initialize
    @label = nil
  end

  attr_reader :label #: String?

  #: (untyped) -> untyped
  def bump(x)
    x
  end
end

c = Counter.new
p c.label
p c.bump(5)
