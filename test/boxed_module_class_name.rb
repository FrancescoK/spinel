module Cmp; end
class Foo; end
x = [Cmp, String, Foo, Comparable]
p x[0].class
p x[0].class.name
p x[3].class
p x[1].class
p x[2].class
p x[0]
puts x[0].inspect
puts x[0].to_s
p x[0].is_a?(Module)
p x[0].is_a?(Class)
p x[0].instance_of?(Module)
p x[0].instance_of?(Class)
p x[0].class == Module
p x[0].class == Class
p x.map { |c| c.class }
class H
  def initialize(m) = @m = m
  def m = @m
end
h = H.new(x[0])
p h.m.class
hh = {a: Cmp, b: 1}
p hh[:a].class
p hh[:a].is_a?(Class)
p hh[:a].kind_of?(Module)
p hh[:a].instance_of?(Module)
p hh.values.map(&:class)
y = x[0]
case y
when Class then puts "class"
when Module then puts "module"
end
x = [Comparable, 1, Kernel, Integer]
p x[0].class
p x[2].class
p x[3].class
puts x[0].class.name
