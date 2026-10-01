# Klass.try_convert(x) on a boxed x answers x when it already is one of the
# class and nil otherwise, as on a typed x: the boxed x was always nil.
x = Array.new
p Array.try_convert(x)
p Array.try_convert(x).equal?(x)
Array.try_convert(x) << 5
p x

h = Hash.new
p Hash.try_convert(h)
p Hash.try_convert(h).equal?(h)
Hash.try_convert(h)[:a] = 1
p h

class Box
  def initialize(v)
    @v = v
  end

  def same?(o)
    @v.equal?(o)
  end
end
p Box.new(Array.try_convert(x)).same?(x)
p Box.new(Hash.try_convert(h)).same?(h)

vals = [[1, 2], { b: 2 }, "str", 7, 2.5, /re/, nil, :sym]
vals.each do |v|
  p [Array.try_convert(v), Hash.try_convert(v), String.try_convert(v),
     Integer.try_convert(v), Regexp.try_convert(v)]
end
p IO.try_convert(vals[0]), IO.try_convert([$stdout, 1][0]).equal?($stdout)
p Integer.try_convert([2.9, 1][0])
