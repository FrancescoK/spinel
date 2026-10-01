# Regexp.union(*x) where x is not an Array: a splatted String, Regexp or nil
# is the one operand (or none) it makes; a lone Regexp is itself
def f(s = nil) = Regexp.union(*s)
p f
p f("a.b")
p f(/w/i)
p f(["k", "l"])
s = "x+y"
p Regexp.union(*s)
p Regexp.union(*[])
p Regexp.union(*["q", /z/])
one = [/r/m, "t"]
one.pop
p Regexp.union(one)
p Regexp.union(*one)
n = [1]
begin
  Regexp.union(*n)
rescue TypeError
  p :type_error
end
