# Marshal.load on a receiver that holds the Marshal module (handed in as an
# argument, kept in an Array) can mint any class of the program, as the call on
# the constant can: Pt is dumped by CRuby (the bytes below) and built by no
# `new` of this program, yet loads and renders as itself.
class Pt
  def initialize(x) = @x = x
  def to_s = "Pt(#{@x})"
end

class Other
  def initialize = @o = 1
end

def load_with(m, bytes) = m.load(bytes)

bytes = "\x04\bo:\aPt\x06:\a@xi\b".b
o = load_with(Marshal, bytes)
puts o
p o.class
mods = [Marshal, Marshal]
puts mods[0].load(bytes)
puts Marshal.dump(Other.new).size
# a call on the constant that answers the module itself
puts Marshal.freeze.load(bytes)
puts Marshal.itself.load(bytes)
puts Marshal.then { |m| m }.load(bytes)
