# The attr forms a class body declares, as the load record holds them: a
# String name (`attr_accessor "d"`), a form under a constant condition
# (`attr_reader :x if true`, the else of `if false`), one wrapped in a
# visibility word or used as a value, and a `class << self` accessor that
# shares the class-level ivar the class body assigns: also a `class << Foo`
# accessor with the @x a `def self.peek` reads, and an accessor of a later
# `class << self` with the @y an earlier reopening assigns.
class A
  attr :a
  attr_accessor "d"
  attr_reader :x if true
  if false then attr_reader :c else attr_writer :w end
  private attr_reader :hidden
  r = attr_reader :shown
  @count = 10
  class << self
    attr_accessor :count
  end
  def initialize; @a = 1; @d = 2; @x = 3; @hidden = 4; @shown = 5; end
  def peek = [hidden, @w]
end

o = A.new
p o.a, o.d, o.x, o.shown
o.d = 7
o.w = 8
p o.d, o.peek
p A.public_instance_methods(false).sort
p A.private_instance_methods(false).sort
p A.count
A.count += 1
p A.count

class Foo
  class << Foo
    attr_accessor :x
  end
  @x = 3
  def self.peek = @x
end
p Foo.x
Foo.x = 4
p Foo.peek
class Foo
  @y = 10
end
class Foo
  class << self
    attr_reader :y
  end
end
p Foo.y
