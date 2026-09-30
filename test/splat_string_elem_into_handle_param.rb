# A method growing its parameter through a helper whose parameter is boxed
# (another caller hands the helper an Array) takes a shared String handle.
# Called with a splat of a String array, the parameter was handed the
# element's bytes where the handle belongs, and the C did not compile. The
# element takes a handle of its own, as a String argument does.

def grow(v) = v << "x"
grow([])

def one(a) = (grow(a); a)
def two(a, b = +"d") = (grow(a); grow(b); [a, b])

p one(*[+"s"])
p two(*[+"t"])
p two(*[+"u", +"w"])

class K
  def one(a) = (grow(a); a)
  def self.one(a) = (grow(a); a)
end
p K.new.one(*[+"k"])
p K.one(*[+"c"])

# fresh elements through the splat, each wrapped
out = []
100.times { |i| out << one(*["e#{i}"]) }
p out.size, out.last
