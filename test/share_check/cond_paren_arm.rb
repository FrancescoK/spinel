# A conditional's arm of parentheses holding several statements answers
# the last one: here a String an instance variable also holds, which a
# change through either name shows, so the plan gives the conditional
# that String's handle rather than a new one around its bytes.
c = ARGV.size == 0
t = c ? (x = 1; @j = +"s") : +"n"
@j << "?"
p t, t.equal?(@j)
u = c ? (x = 2; @k = +"k") : nil
u << "!"
p @k, u.equal?(@k)
v = c ? () : +"e"
p v
