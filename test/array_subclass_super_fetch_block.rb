# An Array subclass's fetch that reaches Array's through super, with the
# caller's block and a splat of the rest (#7449): the block was read as an
# empty one, and the splat was handed on as one default.
class L < Array
  def fetch(i, *extras) = super(i, *extras)
end
l = L.new([1])
p l.fetch(5) { |i| i * 2 }
p l.fetch(0)
p l.fetch(7, :dflt)
class M < Array
  def fetch(i) = super(i)
end
m = M.new([3])
p m.fetch(4) { |i| i + 100 }, m.fetch(0)
