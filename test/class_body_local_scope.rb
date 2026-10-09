# A class, module or singleton class body is a local scope of its own: its
# locals are not the top level's, nor another body's. spinel emitted the
# bodies into the top level's C function with one variable per name, so
# `module M; a = 5; end; a ||= 10` left a at 5.
module M
  a = 5
  b = [1, 2].map { |x| x + a }
  p b
end
class C
  a = "str"
  p a
  class << self
    a = :sym
    p a
  end
  p a
end
a ||= 10
p a
p defined?(b)
items = []
class D
  items = [:d]
  p items
end
p items
