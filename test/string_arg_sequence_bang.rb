# An argument that is a parenthesized sequence ending in a bang on a shared
# String, collected by a rest parameter, hands on the String's handle:
# the change the callee makes shows in the variable. The arm test took the
# parentheses for the leaf, not the bang in them, so the callee changed a
# copy.
def m2(*t) = t[0] << "!"

a = +"a"
k = 1 + ARGV.size
m2((k; a.upcase!))
p a
