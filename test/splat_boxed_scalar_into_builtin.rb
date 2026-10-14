# A splat of a boxed local that holds no Array spreads as one argument,
# into a builtin whose argument count is only known at run time: the
# length dispatch read the operand's length and raised NoMethodError for
# an Integer. A boxed Array and nil spread as before.
mixed = [5, "x", [3, 4], nil, 2]
s = mixed[0]
p 17.divmod(*s)
p({5 => 1}.fetch(*s))
p [1, 5, 3].find_index(*s)
a = [[1, 2], [3, 4]]
three = mixed[0] - 2
p a.assoc(*three)
two = mixed[2]
p({3 => 9}.fetch(*two))
n = mixed[3]
p [1, 2].first(*n)
w = mixed[4]
p 7.divmod(*w)
