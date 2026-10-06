# A pattern binds t to the String the matched Array holds, s itself, so the
# append changes s. t held a copy and s stayed "abc": refused, not compiled
# wrong.
s = +"abc"
case [s]
in [t]
  t << "!"
end
p s
