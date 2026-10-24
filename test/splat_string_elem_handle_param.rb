# A splat of a String Array spread into String parameters held each
# element's bytes in a handle temp, which did not compile (a reopened
# `File.join(*xs, sep:)` given `*a`); the parameter takes the element's
# handle, so a change through it reaches the element.
class File
  def self.join(*xs, sep: "/") = xs.join(sep) + "!"
end
a = [+"x", +"y"]
p File.join(*a)
def two(p, q) = p << q
b = [+"m", +"n"]
two(*b)
p b
