# spinel: share
# spinel: gc-minor
# An operation on an Array of shared Strings that a method answers evaluates
# that call before its argument: the call's block can rebind the variable the
# argument reads.
def get(a)
  yield
  a
end
t = +"t"
a = [t, +"x"]
t << "!"
sep = "-"
p get(a) { sep = "|" }.join(sep)
n = "zz"
p get(a) { n = "x" }.include?(n)
b = [t, +"x"]
p get(a) { sep = "+" }.join(sep), get(b) { n = "t!" }.include?(n)
p get(a) { }.join(sep), get(a) { }.include?(n)
