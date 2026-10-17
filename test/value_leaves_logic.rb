# A method that answers an Array through `&&` or `||`. The Array is an Array
# of Integers until `use` appends a String to what the method answered, which
# widens every Array the operands can answer. The walk that finds those
# Arrays stopped at the operator, so the Integer Array stayed typed and the
# append was refused (an Array[Integer] passed to a parameter the method
# mutates) or raised TypeError at run time. `a && b` answers `b` or a falsy
# `a`, which is never an Array: only its right side is a position; `a || b`
# answers either.
def use(q)
  q << "s"
end

def conjunction
  ARGV.empty? && [1, 2]
end

def disjunction
  ARGV.empty? && [3] || [4]
end

def plain_or(x)
  x || [5, 6]
end

def chain(x, y)
  x || y || [7]
end

def in_a_return(flag)
  return flag && [8] if flag
  [9] || [10]
end

[conjunction, disjunction, plain_or(nil), plain_or([0]), chain(nil, nil),
 chain(nil, [1]), in_a_return(true), in_a_return(false)].each do |a|
  use(a)
  p a
end
