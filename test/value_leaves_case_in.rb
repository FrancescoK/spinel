# A method that answers an Array from the arms of a case/in, with an else and
# without one. The Array is an Array of Integers until `use` appends a String
# to what the method answered, which widens every Array the arms can answer.
# The walk that finds those Arrays stopped at the case/in, so the Integer
# Array stayed typed and the append was refused (an Array[Integer] passed to a
# parameter the method mutates) or raised TypeError at run time.
def use(q)
  q << "s"
end

def with_else(n)
  case n
  in 0 then [1, 2]
  in Integer => k if k > 5 then [3]
  else [4]
  end
end

def without_else(n)
  case n
  in 0 then [5]
  in 1 then [6, 7]
  end
end

def in_a_return(n)
  return [8] if n == 8
  case n
  in 0 then [9]
  in 1 then [10]
  end
end

[with_else(0), with_else(7), with_else(1), without_else(0), without_else(1),
 in_a_return(0), in_a_return(8)].each do |a|
  use(a)
  p a
end
begin
  without_else(2)
rescue NoMatchingPatternError
  puts "no pattern"
end
