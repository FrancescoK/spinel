# A pattern binding into a local an earlier assignment typed (a Class, a
# Hash, a Symbol, an object) stores the matched value at the local's type.
class Pt
  def initialize(x) = @x = x
  attr_reader :x
end

def a(n, k)
  m = String
  case k
  in [m] if n == 2
  else
  end
  m.name
end
puts a(1, [Integer])

def s(k)
  y = :none
  case k
  in [y, 1]
  else
  end
  y.to_s
end
puts s([:ok, 1])

def o(k)
  q = Pt.new(0)
  case k
  in {pt: q}
  else
  end
  q.x
end
p o({pt: Pt.new(5)})

def h(k)
  r = {a: 1}
  case k
  in [*, r, 9]
  else
  end
  r.keys
end
p h([1, {b: 2}, 9])

def c2(k)
  z = Float
  case k
  in [Class => z]
  else
  end
  z.name
end
puts c2([Symbol])
