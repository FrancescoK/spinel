# A receiver typed A | B calls a blockless `group_by` both classes define:
# the dispatch's default arm (a Hash receiver, whose blockless group_by is an
# Enumerator) stored the Enumerator into the boxed result unboxed, and the
# C did not compile (#7279).
class A
  def group_by
    { a: 1 }
  end
end

class B
  def group_by
    ["x"]
  end
end

def pick(flag)
  flag ? A.new : B.new
end

def f(flag)
  pick(flag).group_by
end

p f(true)
p f(false)

def g(x) = x.group_by
[A.new, B.new, { k: 1, j: 2 }].each do |x|
  r = g(x)
  p r.is_a?(Enumerator) ? r.to_a : r
end
