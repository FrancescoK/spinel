# `then` answers its block's value, here the receiver itself, so r is s.
# The answer was a copy and s stayed "abc": refused, not compiled wrong.
s = +"abc"
r = s.then { |x| x }
r << "!"
p s
