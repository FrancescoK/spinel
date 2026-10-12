# A method whose value is a String bang `||` its own receiver
# (`a.squeeze!("b") || a`) answers that receiver's String whether or not
# the bang changed it; `a.upcase! && a` answers it, or nil when the bang
# changed nothing. The answer, changed in place, is the caller's String.
# An operand or a method's value that appends to the receiver inside
# parentheses, a conditional's or a case's arm or a `return` answers it too.
def squeeze_or(a)
  a.squeeze!("b") || a
end

def upcase_or(a)
  return a.upcase! || a
end

def upcase_and(a)
  a.upcase! && a
end

def tr_or_fresh(a)
  a.tr!("a", "q") || (a + "!")
end

def strip_or_nil(a)
  a.strip! || nil
end

def first_or(arr)
  arr[0].downcase! || arr[0]
end

class Box
  attr_reader :s

  def initialize(s)
    @s = s
  end

  def swap
    (@s.swapcase! rescue @s) || @s
  end
end

$g = +"glob"
def global_or
  $g.capitalize! || $g
end

def and_paren(a)
  a.upcase! && (a << "z")
end

def and_tern(a, b, f)
  b && (f ? a << "z" : a)
end

def and_case(a, b)
  b && case a.size when 2 then a << "z" else a end
end

def pick(a, f) = f ? a : nil

def or_paren(a, b, f)
  pick(a, f) || (b << "z")
end

def paren_tail(a) = (a << "z")

def case_tail(a, k)
  case k when 1 then a << "z" else a end
end

def return_paren(a, f)
  return(a << "z") if f
  a
end

r = squeeze_or(+"abba")
r << "!"
p r
r = squeeze_or(+"ab")
r << "!"
p r
r = upcase_or(+"ab")
r << "?"
p r
r = upcase_or(+"AB")
r << "?"
p r
r = upcase_and(+"ab")
r << "&"
p r
p upcase_and(+"AB")
r = tr_or_fresh(+"ab")
r << "1"
p r
r = tr_or_fresh(+"xy")
r << "2"
p r
p strip_or_nil(+" x "), strip_or_nil(+"x")
r = first_or([+"AB"])
r << "e"
p r
b = Box.new(+"aB")
r = b.swap
r << "!"
p r
r = global_or
r << "$"
p r
s = +"ab"
p and_paren(s), s
p and_tern(s, +"q", true), and_tern(s, +"q", false), s
p and_case(+"ab", +"q"), and_case(+"abc", nil)
t = +"cd"
p or_paren(+"ab", t, false), or_paren(+"ab", t, true), t
p paren_tail(+"ab"), case_tail(+"ab", 1), case_tail(+"ab", 2)
p return_paren(+"ab", true), return_paren(+"ab", false)
