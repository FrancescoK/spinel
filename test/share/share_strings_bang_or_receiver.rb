# Under --share-strings a method whose value is a String bang `||` its own
# receiver answers that receiver's String, changed by the bang or not; `&&`
# answers it, or nil, and a ternary on the bang alike. Changed through
# either name, the change shows through the other. A fresh or literal
# right operand answers a String of its own.
def squeeze_or(a)
  a.squeeze!("b") || a
end

def sub_or(a)
  return a.sub!("a", "z") || a
end

def chain_or(a)
  a.upcase! || a.downcase! || a
end

def upcase_and(a)
  a.upcase! && a
end

def tern(a)
  a.upcase! ? a : a
end

def rescue_or(a)
  (a.upcase! rescue a) || a
end

def or_rescue(a)
  a.upcase! || a rescue a
end

def plus_or(a)
  a.chomp! || (a + "p")
end

def lit_or(a)
  a.delete!("b") || "lit"
end

def arm_or(a, g)
  if g
    a.reverse! || a
  else
    a
  end
end

def first_or(arr)
  arr[0].gsub!("b", "") || arr[0]
end

class Box
  attr_reader :s

  def initialize(s)
    @s = s
  end

  def swap
    @s.swapcase! || @s
  end
end

$g = +"glob"
def global_or
  $g.capitalize! || $g
end

def show(r, s)
  p [r, s, r.equal?(s)]
end

def run(inp)
  s = +inp
  r = squeeze_or(s)
  r << "!"
  show(r, s)
  s = +inp
  r = sub_or(s)
  s << "?"
  show(r, s)
  s = +inp
  r = chain_or(s)
  r << "c"
  show(r, s)
  s = +inp
  r = upcase_and(s)
  r << "&" if r
  p [r, s]
  s = +inp
  r = tern(s)
  r << "t"
  show(r, s)
  s = +inp
  r = rescue_or(s)
  r << "r"
  show(r, s)
  s = +inp
  r = or_rescue(s)
  s << "o"
  show(r, s)
  s = +inp
  r = plus_or(s)
  r << "+"
  show(r, s)
  s = +inp
  r = lit_or(s)
  p [r, s, r.frozen?]
  s = +inp
  r = arm_or(s, true)
  r << "v"
  show(r, s)
  s = +inp
  arr = [s]
  r = first_or(arr)
  r << "e"
  show(r, s)
  b = Box.new(+inp)
  r = b.swap
  r << "!"
  show(r, b.s)
  $g = +inp
  r = global_or
  $g << "$"
  show(r, $g)
end

run("abba")
run("Q")
