# A value-type receiver in a poly dispatch arm: its defaults read ivars and
# `self` off the dereferenced value, which is what the callee takes.
# spinel: gc-stress
# (Such a value held in a temp, R's default `sep = self` among them, is a
# struct by value: its String fields are rooted, not the struct, which the
# mark walk read as a heap pointer and faulted on under SPINEL_GC_STRESS=2.)
class P
  def initialize(b)
    @b = b
  end

  def join(sep = @b)
    P.new(@b + sep)
  end

  def to_s
    @b
  end
end

class R
  def initialize(b)
    @b = b
  end

  def join(sep = self)
    R.new(@b + sep.to_s)
  end

  def to_s
    @b
  end
end


class S
  def initialize(b)
    @b = b
  end

  def join(part, sep = self)
    S.new(@b + part + sep.to_s)
  end

  def to_s
    @b
  end
end


def show(v)
  v.join
end

def show_part(v)
  v.join("-")
end

puts show([1, 2])
puts show(["a", "b"])
puts P.new("x").join.to_s
puts R.new("y").join.to_s
puts show_part([1, 2])
puts show_part(["a", "b"])
puts S.new("z").join("-").to_s
