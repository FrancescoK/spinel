# Under --share-strings a method whose value is a String bang `||` its own
# receiver answers that receiver's String, changed by the bang or not; `&&`
# answers it, or nil, and a ternary on the bang alike. Changed through
# either name, the change shows through the other. A fresh or literal
# right operand answers a String of its own. So does an operand, or a
# method's value, that appends to the receiver inside parentheses, a
# conditional's or a case's arm, a rescue modifier or a `return`: the
# append answers the receiver's String.
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

def and_paren(a)
  a.upcase! && (a << "z")
end

def and_concat(a, b)
  b && (a.concat("z"))
end

def and_if(a, b)
  b && (if b.size > 0 then a << "z" else a end)
end

def and_tern(a, b, f)
  b && (f ? a << "z" : a)
end

def and_case(a, b)
  b && case a.size when 2 then a << "z" else a end
end

def and_case_in(a, b)
  b && case b.size
       in 1 then a << "z"
       else a
       end
end

def and_rescue(a, b)
  b && (a << "z" rescue a)
end

def pick(a, f) = f ? a : nil

def or_paren(a, b, f)
  pick(a, f) || (b << "z")
end

def or_tern(a, b, f)
  pick(a, f) || (f ? b : b << "z")
end

def paren_tail(a) = (a << "z")

def concat_tail(a) = (a.concat("z"))

def case_tail(a, k)
  case k when 1 then a << "z" else a end
end

def return_paren(a, f)
  return(a << "z") if f
  a
end

def tern_paren(a, f)
  f ? (a << "z") : nil
end

def rescue_tail(a)
  a << "z" rescue a
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

def wrapped(inp)
  s = +inp
  r = and_paren(s)
  r << "!" if r
  p [r, s]
  s = +inp
  r = and_concat(s, +"q")
  r << "!"
  show(r, s)
  s = +inp
  r = and_if(s, +"q")
  s << "!"
  show(r, s)
  [true, false].each do |f|
    s = +inp
    r = and_tern(s, +"q", f)
    r << "!"
    show(r, s)
  end
  s = +inp
  r = and_case(s, +"q")
  r << "!"
  show(r, s)
  s = +inp
  r = and_case_in(s, +"q")
  r << "!"
  show(r, s)
  s = +inp
  r = and_rescue(s, +"q")
  r << "!"
  show(r, s)
  [true, false].each do |f|
    s = +inp
    t = +"cd"
    r = or_paren(s, t, f)
    r << "!"
    p [r, s, t]
    s = +inp
    t = +"cd"
    r = or_tern(s, t, f)
    r << "!"
    p [r, s, t]
  end
  s = +inp
  r = paren_tail(s)
  r << "!"
  show(r, s)
  s = +inp
  r = concat_tail(s)
  r << "!"
  show(r, s)
  [1, 2].each do |k|
    s = +inp
    r = case_tail(s, k)
    r << "!"
    show(r, s)
  end
  [true, false].each do |f|
    s = +inp
    r = return_paren(s, f)
    r << "!"
    show(r, s)
  end
  s = +inp
  r = tern_paren(s, true)
  r << "!"
  show(r, s)
  p tern_paren(s, false)
  s = +inp
  r = rescue_tail(s)
  s << "!"
  show(r, s)
end

wrapped("ab")
wrapped("AB")
