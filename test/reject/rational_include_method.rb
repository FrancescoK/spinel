# A method a module included into Rational adds has no arm on a Rational
# value: refused at compile time instead of raising NoMethodError at run time.
module Desc
  def desc = "value"
end
class Rational
  include Desc
end
p 3r.desc
