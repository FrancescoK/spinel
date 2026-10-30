# super(args, &s) with s a local holding a Symbol hands the parent's &b,
# yield or a kept proc the Symbol's block, reading s where super runs.
class A
  def m(a, &b)
    b ? b.call(a) : "no block"
  end

  def each_up(xs, &b)
    xs.map(&b)
  end

  def y(a)
    yield a
  end

  def keep(&b)
    @kept = b
  end

  def run(x)
    @kept.call(x)
  end
end

class B < A
  def m(a)
    s = :upcase
    super(a, &s)
  end

  def each_up(xs)
    s = :reverse
    super(xs, &s)
  end

  def y(a)
    s = :length
    super(a, &s)
  end

  def keep
    s = :capitalize
    r = super(&s)
    s = :upcase
    r
  end
end

b = B.new
puts b.m("hi")
p b.each_up(["ab", "cd"])
p b.y("four")
b.keep
puts b.run("ruby")
class C < A
  def m(a)
    out = []
    2.times do |i|
      s = i == 0 ? :swapcase : :downcase
      out << super(a, &s)
    end
    out
  end
end
p C.new.m("MiX")
