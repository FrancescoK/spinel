# A constant path through a class or module of the program does not reach
# a constant only the top level defines (CRuby's NameError since Ruby 2.5);
# one a body, an ancestor, an included module or a path write defines it
# through is found as before, and so is Object::NAME.
LIMIT = 10
TOP_ONLY = 5
module M
  X = 1
  module Inner
    Y = 2
  end
end
class Base
  B = 3
end
class Sub < Base; end
module Mix
  MX = 4
end
class Inc
  include Mix
end
class Point; end
Point::PATH = 6
class Shadow
  LIMIT = 7
end
p M::X, M::Inner::Y, Sub::B, Inc::MX, Point::PATH, Shadow::LIMIT, Object::LIMIT, LIMIT
class Point
  def lim = LIMIT
end
p Point.new.lim
[[-> { Point::LIMIT }, "Point"], [-> { M::TOP_ONLY }, "M"], [-> { Sub::TOP_ONLY }, "Sub"]].each do |f, _|
  begin
    p f.call
  rescue NameError => e
    p e.message
  end
end

# a path write through an unrelated class does not define the name for
# another class's path; one through an ancestor does
class Other; end
Other::TOP_ONLY = 9
Base::VIA_BASE = 8
p Other::TOP_ONLY, Sub::VIA_BASE
begin
  p Point::TOP_ONLY
rescue NameError => e
  p e.message
end
