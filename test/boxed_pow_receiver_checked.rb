# pow on a boxed receiver: Integer alone has it, so nil, a Symbol, a
# String, an Array, a Hash, a Range and a Float raise NoMethodError (with
# the exponent as its args), where the receiver was converted for `**`:
# a TypeError, an ArgumentError, or a Float's answer. `**` on a Float, and
# an Integer's pow, answer as before.

def t
  p yield
rescue NoMethodError => e
  puts "#{e.message} #{e.args.inspect}"
rescue => e
  puts "#{e.class}: #{e.message}"
end

# the operator's message alone: its args are another change's
def t2
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end

k = ARGV.size
[nil, :sy, "s", [1, 2], {a: 1}, 2.5, 1..2, 3].each do |v|
  n = [v, 0][k]
  t { n.pow(2) }
  t { n.pow(2, 5) }
  t2 { n ** 2 }
end

# `**=` on a boxed local, a Hash value, an Array element and an ivar
class Box
  def initialize(v)
    @v = v
  end

  def sq
    @v **= 2
    @v
  end
end
[nil, "s", 3, 2.5].each do |v|
  x = [v, 0][k]
  t2 { x **= 2; x }
  h = { a: [v, 0][k] }
  t2 { h[:a] **= 2; h[:a] }
  a = [[v, 0][k]]
  t2 { a[0] **= 2; a[0] }
  t2 { Box.new([v, 0][k]).sq }
end
