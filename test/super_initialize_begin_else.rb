# `super` in the body of a begin that has an else clause, whose value is
# used. The value of such a begin is its else's: the body's value is thrown
# away, so the `super` is not read. initialize is compiled to return
# nothing, and a `super` whose value is used is refused, so the body was
# taken for the begin's value, which a local keeps, and the program was
# refused. The body is thrown away now.
class Base
  attr_reader :x
  def initialize(x)
    @x = x
  end
end

class Sub < Base
  attr_reader :y

  def initialize(x)
    @y = begin
      super
    rescue ArgumentError
      0
    else
      x * 2
    end
  end
end

s = Sub.new(21)
p s.x
p s.y
