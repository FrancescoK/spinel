# A constant slot can hold a runtime class and values of other kinds.
def make = Class.new { def hi = 7 }

Late = make
later = -> { Late = 5 }
p Late.new.hi
later.call
begin
  Late.new
rescue NoMethodError => e
  puts e.message
end

Reset = make
define_method(:reset) { Reset = nil }
p Reset.new.hi
reset
begin
  Reset.new
rescue NoMethodError => e
  puts e.message
end

Multi = make
A, Multi = 1, 2 if [].size > 0
p Multi.new.hi

Conditional = make
Conditional = 5 if [].size > 0
p Conditional.new.hi

OrWrite = make
OrWrite ||= 5
p OrWrite.new.hi

Iterator = make
[].each { Iterator = 5 }
p Iterator.new.hi

# An opaque mixin does not make another owner's constant visible.
module Other
  K = Object.send(:make)
end
class C
  include Math
  def f = K.new.hi
end
begin
  p C.new.f
rescue NameError => e
  p e.class
end

module Visible
  K = Object.send(:make)
  class C
    include Math
    def f = K.new.hi
  end
end
p Visible::C.new.f

def Other.root = ::K.new.hi
begin
  p Other.root
rescue NameError => e
  p e.class
end

# A visible history may contain only conditional or deferred writes.
MayOnly = make if [].size == 0
p MayOnly.new.hi
install = -> { DeferredOnly = make }
install.call
p DeferredOnly.new.hi
