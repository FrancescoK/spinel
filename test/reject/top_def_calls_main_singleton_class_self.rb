# The same with main's method defined in a `class << self` body.
class << self
  def k = "sc"
end
def k = "obj"
def w = k
p w
