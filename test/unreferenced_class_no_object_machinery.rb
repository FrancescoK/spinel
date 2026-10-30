# Classes and a module that nothing in the program uses build no object, so
# nothing renders one: the per-class object switches (inspect, to_s and the
# conversions behind them) and the hooks that install them are not written,
# and no constructor is either. The class bodies still run, and a class
# method or a constant of such a class still works (the generated C is
# checked by `make infer-test`).
class NeverReferenced
end

class NeverReferencedWithMethods
  LIMIT = 3
  puts "body of NeverReferencedWithMethods runs"

  def initialize(a, b)
    @a = a
    @b = b
  end

  def to_s
    "never #{@a} #{@b}"
  end

  def inspect
    "#<never>"
  end

  def total
    @a + @b
  end

  def self.limit
    LIMIT
  end
end

module NeverIncluded
  def shout
    to_s.upcase
  end

  def self.helper
    :helper
  end
end

class NeverReferencedSubclass < NeverReferencedWithMethods
  include NeverIncluded
end

puts "x"
puts NeverReferencedWithMethods.limit
puts NeverIncluded.helper
puts NeverReferencedWithMethods::LIMIT
puts defined?(NeverReferenced).inspect
