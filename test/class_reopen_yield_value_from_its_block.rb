# spinel: int64
# A yielding method a program adds to Class, called on a builtin class,
# yields its call's block value: in a method's tail, through a nested
# bare call of another such method, and with a value past 2**31.
class Class
  def calc = yield * 3

  def show
    puts yield * 3
  end

  def wrap
    "[" + yield.to_s + "]"
  end

  def wrap2
    wrap { yield + 1 }
  end

  def wrap_say
    puts "[" + yield.to_s + "]"
  end

  def wrap_say2
    wrap_say { yield + 1 }
  end
end

def t = Integer.calc { 1 }
p t
Integer.show { 2**40 }
Integer.show { 1 }
String.wrap_say2 { 1 }
def u = String.wrap { 7 }
p u
