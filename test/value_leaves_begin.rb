# A method that answers an Array through a begin: the plain one, one with
# rescue clauses, and one with an else. The Array is an Array of Integers
# until `use` appends a String to what the method answered, which widens
# every Array the begin's arms can answer. The walk that finds those Arrays
# stopped at the begin, so the Integer Array stayed typed and the append was
# refused ("an Array[Integer] is passed to `use`'s parameter ...") or raised.
def use(q)
  q << "s"
end

def plain
  begin
    [1, 2]
  end
end

def rescued
  begin
    raise ArgumentError, "x" if ARGV.size > 5
    [3]
  rescue ArgumentError
    [4]
  end
end

def with_else
  begin
    raise ArgumentError, "x" if ARGV.size > 5
    7
  rescue ArgumentError
    [5]
  else
    [6, 7]
  end
end

def after_return(flag)
  return [8] if flag
  begin
    [9]
  rescue TypeError
    [10]
  end
end

[plain, rescued, with_else, after_return(false), after_return(true)].each do |a|
  use(a)
  p a
end
