# A program in which no class can have an object writes none of the per-class
# object switches, yet code that names one still compiles: `def inspect =
# super` and `def to_s = super` in a class nothing builds, and `p` or
# `inspect` of a value typed as such a class (here only ever nil).
class Never
  def initialize
    @a = 1
  end

  def inspect = super

  def to_s = super

  def self.make = 3
end

class NeverToS
  def to_s = super
end

class NeverInspect
  def inspect = super
end

def show(k)
  p k
end

p Never.make
p [1].inspect
show(nil)
x = nil
p x.inspect
puts "done"

# a call of Module#allocate before the module defines its own: typed as an
# object of the module, which can have none
module Lone
  begin
    p Lone.allocate
  rescue NoMethodError => e
    puts e.message
  end

  def self.allocate = 8
end
