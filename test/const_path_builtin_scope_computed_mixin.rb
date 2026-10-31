# A mixin whose module is computed (an include from a method with the module
# in a parameter) can give a builtin any name, so no path through a builtin
# is called missing in the program: the constants such a module holds are
# read through the builtin, as CRuby does.
class Cx1; def self.v = 81; end
class Cx2; def self.v = 82; end
module Mc1; MA1 = Cx1; end
module Mc2; Cx2 = ::Cx2; end

class Array
  def self.mix(m) = include(m)
end
class StandardError
  def self.mix(m) = include(m)
end
Array.mix(Mc1)
StandardError.mix(Mc2)

def try
  p yield
rescue NameError => e
  puts "NameError: #{e.message}"
end

try { Array::MA1.v }
try { ArgumentError::Cx2.v }
try { Cx1.v }
