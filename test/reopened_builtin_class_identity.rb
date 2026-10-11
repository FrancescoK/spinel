# Reopening a builtin class gives the reopening a class id of its own, but
# the builtin's values keep the builtin's: the constant still names the same
# class for ===, is_a?, ==, <, superclass and ancestors.
class Module
  def infect_it(meth) = meth
end

class Class
  def zz = 1
end

module Ext
  class ::Integer
    def dbl = self * 2
  end
end

module Quiet; end
module Loud
  include Quiet
end

class String
  prepend Loud
  include Comparable
  def shout = upcase
end

class ArgumentError
  def extra = 1
end

module Comparable
  def cmp_extra = 2
end

class MyErr < ArgumentError; end

p Module === ArgumentError
p [ArgumentError, String, Comparable].all?(Module)
p Class === Comparable
p Module === Comparable
p Class.superclass
p Class.superclass == Module
p Integer.superclass
p Integer < Numeric
p String <= Comparable
p String.ancestors.include?(Comparable)
p Integer.ancestors.first(3)
p ["a", 1, :s].grep(String)
p [1, 2.0].count { |x| Integer === x }
p MyErr.ancestors.include?(StandardError)
p MyErr.new.is_a?(ArgumentError)
p MyErr <= StandardError
begin
  raise MyErr, "x"
rescue ArgumentError => e
  p [:rescued, e.class]
end
case Comparable
when Class then p :class
when Module then p :module
end
h = { Module => 1, Integer => 2 }
p h[Class.superclass], h[1.class]
p Module.name, Class.name, Integer.to_s
p String.ancestors.first(3)
p String <= Loud
p Loud === "a"
p 3.dbl
p String <= Quiet
p String.ancestors.count(Comparable)
