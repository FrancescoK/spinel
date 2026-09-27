# `super` inside `def self.new` with no class method `new` above it is
# Class#new: it allocates the receiving class and runs its initialize. It
# raised "super: no superclass method 'new'" (and `puts C.new(7)` was refused
# at compile time, the call being untyped). Covers arguments, a bare `super`
# forwarding the parameters, an inherited `self.new` building the subclass,
# and a static call reaching an inherited `self.new` that reads `name`,
# which was handed no receiving class and failed in C.
class C
  def self.new(x) = super(x * 10)
  def initialize(x) = @x = x
  def to_s = "C(#{@x})"
end
c = C.new(7)
puts c
puts C.new(1)
class P
  def self.new(a, b = 2) = super
  def initialize(a, b) = (@a = a; @b = b)
  def to_s = "#{self.class.name}(#{@a}, #{@b})"
end
class Q < P
  def initialize(a, b) = (@a = a * 2; @b = b)
end
puts P.new(1)
puts Q.new(1, 5)
class R
  def self.new(*) = super()
  def initialize = @r = :r
  def to_s = "R(#{@r})"
end
puts R.new(1, 2)
class N
  def self.new(x) = "#{name}:#{x}"
end
class M < N; end
puts N.new(1)
puts M.new(2)
