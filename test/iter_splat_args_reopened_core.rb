# the argument count an iterator handed a splat checks, and its message, are
# the builtins' own: a program that reopens Array#length, Integer#> or
# String#+ does not change them

class Array
  def length = 0
end
class Integer
  def >(o) = false
end
class String
  def +(o) = "plus"
end

def f(a, *s) = a.each(*s) { |x| }
p((f([1], :x) rescue $!.message))
p f([2])
