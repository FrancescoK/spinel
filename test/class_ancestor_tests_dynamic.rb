# Class and module tests decided at run time -- is_a?, kind_of?, === and
# instance_of? with a class or module held in a variable, and Class#<, <=,
# >, >= and <=> -- walk the ancestors (prepends, includes, the builtin
# chain and its modules) and stop at the first match, without building the
# ancestors array; ancestors and included_modules still build it.
module Greet; end
module Loud; end
module Pre; end
class Animal; include Greet; end
class Dog < Animal; include Loud; prepend Pre; end
class Cat < Animal; end

p Dog.ancestors.take(5), Cat.ancestors.take(3)
p Dog.included_modules.take(3)
klasses = [Dog, Cat, Animal, Greet, Loud, Pre, Comparable, Kernel, Object, BasicObject, Integer, Numeric, String]
vals = [Dog.new, Cat.new, 3, "s", 2.5, nil, [1], :sym]
vals.each do |v|
  puts klasses.map { |k| v.is_a?(k) ? 1 : 0 }.join + " " + klasses.map { |k| k === v ? 1 : 0 }.join + " " + klasses.map { |k| v.kind_of?(k) ? 1 : 0 }.join
end
pairs = [[Dog, Animal], [Animal, Dog], [Dog, Greet], [Dog, Loud], [Dog, Pre], [Dog, Dog], [Dog, Object], [Integer, Comparable], [Greet, Dog]]
pairs.each { |a, b| p [a < b, a <= b, a > b, a >= b, a <=> b] }
n = 0
k = [Greet, Loud][1]
20000.times { |i| n += 1 if [Dog.new, Cat.new][i % 2].is_a?(k) }
p n
