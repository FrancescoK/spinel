# `class << obj` places its defs on the object's own class when the program
# is compiled; an attr_accessor there has no such place and would be
# dropped, so the body is refused.
o = Object.new
class << o
  attr_accessor :x
end
o.x = 1
p o.x
