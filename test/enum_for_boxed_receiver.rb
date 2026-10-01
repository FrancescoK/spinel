# enum_for / to_enum on a boxed value, as Rack::Lint's `@body.enum_for.to_a`:
# an object whose class iterates by a yielding each, or a builtin Array,
# Hash or Range, each enumerated as it would be typed.
class Parts
  def initialize(*xs) = @xs = xs

  def each
    @xs.each { |x| yield x }
  end
end

vals = [[1, 2], Parts.new(:a, :b), { k: 1 }, (1..3)]
vals.each { |v| p v.enum_for.to_a }
p vals[1].to_enum.map { |x| x.to_s * 2 }
e = vals[0].enum_for
p e.next, e.next
p Parts.new(3, 4).enum_for.to_a
