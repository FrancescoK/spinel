# Flag-only. A pattern over an object binds its variables to the parts its
# own deconstruct or deconstruct_keys answers: the String an ivar holds, not
# a copy of it. Also through a named class (`in Box[t]`), a value that may
# be any object, a rest, `=>`, two parts, an explicit deconstruct call, a
# deconstruct that calls `super`, and a literal a method answers by `return`.

class Box
  def initialize(s); @s = s; end
  def deconstruct; [@s]; end
  def deconstruct_keys(keys); { name: @s }; end
  def s; @s; end
end

class Pair
  def initialize(a, b); @a = a; @b = b; end
  def deconstruct
    parts = [@a, @b]
    parts
  end
end

class Inner
  def initialize(s); @s = s; end
  def deconstruct; [@s]; end
  def pair
    return [@s]
  end
end

class Outer < Inner
  def deconstruct; super; end
end

def through_super
  s = +"ab"
  case Outer.new(s)
  in [t]
    t << "m"
  end
  p s
end

def explicit_return
  s = +"ab"
  t = Inner.new(s).pair[0]
  t << "n"
  p s
end

def array_pattern
  s = +"ab"
  case Box.new(s)
  in [t]
    t << "c"
  end
  p s
end

def hash_pattern
  s = +"ab"
  b = Box.new(s)
  case b
  in { name: t }
    t << "d"
  end
  p b.s
end

def named_class
  s = +"ab"
  case Box.new(s)
  in Box[t]
    t << "e"
  end
  p s
end

def any_value(k)
  s = +"ab"
  o = k > 0 ? Box.new(s) : k
  case o
  in Box[t]
    t << "f"
  in Integer
  end
  p s
end

def rest_pattern
  s = +"ab"
  case Box.new(s)
  in [*r]
    r[0] << "g"
  end
  p s
end

def rightward
  s = +"ab"
  Box.new(s) => [t]
  t << "h"
  Box.new(s) => { name: u }
  u << "i"
  p s
end

def two_parts
  a = +"ab"
  b = +"xy"
  case Pair.new(a, b)
  in [x, y]
    x << "j"
    y << "k"
  end
  p a
  p b
end

def explicit_call
  s = +"ab"
  t = Box.new(s).deconstruct[0]
  t << "l"
  p s
end

array_pattern
hash_pattern
named_class
any_value(1)
rest_pattern
rightward
two_parts
explicit_call
through_super
explicit_return
