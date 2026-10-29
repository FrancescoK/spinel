# An Integer Array or a Float Array read out of a mixed Array is a boxed
# value. include? and delete compare its elements with == as CRuby does,
# so an Integer finds the Float of its value and a Float the Integer.
b = [[1, 2], [1.0, 2.0], "s"]
p b[0].include?(2.0)
p b[0].include?(2.5)
p b[1].include?(2)
p b[1].include?(3)
p b[0].include?(2r)
p b[1].include?(1r)

# a boxed needle of another kind
x = [2.0, 2][ARGV.size]
y = [2, 2.0][ARGV.size]
z = [nil, 1][ARGV.size]
p b[0].include?(x)
p b[1].include?(y)
p b[0].include?(z)
p b[0].include?("2")

# delete of a Float of an Integer's value removes it and answers the element
c = [[1, 2, 1], "s"]
r = c[0].delete(1.0)
p r, r.class, c
p c[0].delete(2.5), c
p c[0].delete(-0.0), c
d = [[0, 3], "s"]
p d[0].delete(-0.0), d
