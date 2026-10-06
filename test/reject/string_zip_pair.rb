# zip builds pairs of the receiver's and the argument's elements, so the
# pair's second element is s itself. It was a copy and s stayed "abc":
# refused, not compiled wrong.
s = +"abc"
r = [1].zip([s])[0][1]
r << "!"
p s
