# The compile-time warning that a `<<` receiver "only ever holds frozen
# string literals" is for a local every write of which is a literal. One
# that an op-write (`s += "#{n}"`) or an and-write assigns holds that value
# too, and appending to it works; one only literals assign still raises
# FrozenError at run time, as the warning says. The Makefile's infer-test
# checks which of these warn.
n = [3, 4].first
s = "lit"
s += "#{n}"
s << "x"
puts s

m = "m"
m &&= +"mutable"
m << "!"
puts m

text = ""
begin
  text << "line"
rescue FrozenError => e
  puts e.class
end
