# A method whose value is a String bang `||` its own receiver
# (`a.squeeze!("b") || a`) answers that receiver's String whether or not
# the bang changed it; `a.upcase! && a` answers it, or nil when the bang
# changed nothing. The answer, changed in place, is the caller's String.
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
