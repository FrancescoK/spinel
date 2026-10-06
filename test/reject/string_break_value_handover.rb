# `break s` makes s itself the loop's value, so r is s. r held a copy and s
# stayed "abc": refused, not compiled wrong.
s = +"abc"
r = loop { break s }
r << "!"
p s
