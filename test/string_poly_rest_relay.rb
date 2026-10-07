# A String handed through a POLY parameter into the rest of a method that hands
# the rest on (`def relay(*r) = pair(*r)`), to a parameter that appends: the
# appends reach the caller's Strings, not copies (#6782's probe). The Integer
# call keeps the parameters POLY.
def rest_grow(value)
  value << '!' if value.is_a?(String)
  nil
end
def rest_pair(left, right)
  rest_grow(left)
  rest_grow(right)
  nil
end
def rest_relay(*r)
  rest_pair(*r)
  nil
end
def rest_entry(value, other)
  rest_relay(other, value)
  nil
end
rest_entry(1, 2)
a = +"x"
b = +"seed"
alias_a = a
rest_entry(a, b)
p a, b, alias_a
