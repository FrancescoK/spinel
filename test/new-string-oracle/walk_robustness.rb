# The oracle's walk touches the program's objects only through the language's
# own class tests, and counts a variable once however many bindings show it.
# Pt#== raises on anything but a Pt, and the block assigns the toplevel f,
# which the block's own binding shows a second time. walk_robustness.claims
# claims a new String and a one-name String, both true: the oracle must
# disprove neither and raise no error of its own.
class Pt
  attr_reader :n
  def initialize(n) = @n = n
  def ==(other) = @n == other.n
end
$pt = Pt.new(1)
f = +"a"
f.tap { f = +"z" }.upcase!
p f, $pt.n
