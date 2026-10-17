# A method that answers an Array through the rescue modifier. The Array is an
# Array of Integers until `use` appends a String to what the method answered,
# which widens every Array either side can answer. The walk that finds those
# Arrays stopped at the modifier, so the Integer Array stayed typed and the
# append was refused (an Array[Integer] passed to a parameter the method
# mutates) or raised TypeError at run time.
def use(q)
  q << "s"
end

def guarded
  (raise ArgumentError, "x" if ARGV.size > 5; [1, 2]) rescue [3]
end

def recovered
  (raise ArgumentError, "x"; [4]) rescue [5, 6]
end

def in_an_arm(flag)
  if flag
    [7]
  else
    (raise ArgumentError, "x"; [8]) rescue [9]
  end
end

def in_a_return(flag)
  return ([10] rescue [11]) if flag
  [12]
end

[guarded, recovered, in_an_arm(true), in_an_arm(false), in_a_return(true),
 in_a_return(false)].each do |a|
  use(a)
  p a
end
