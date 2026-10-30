# An if in value position whose is_a? predicate folds, with a raising arm
# beside the live one: the result slot is an Integer that may hold nil, and
# the live arm goes into it in that form, as the unfolded if puts each arm.
# Before, the folded arm went in as a plain Integer and the C did not compile.
def strict_int(x)
  n = if x.is_a?(Integer)
    x
  else
    raise TypeError, "not an Integer"
  end
  n + 1
end

def coerce(x)
  n = if x.is_a?(Integer)
    x
  elsif x.is_a?(Float)
    x.to_i
  else
    raise TypeError, "no implicit conversion"
  end
  n * 2
end

def counted(x)
  n = if x.is_a?(Integer)
    y = x + 1
    y
  else
    raise ArgumentError
  end
  n
end

p strict_int(3)
p coerce(4)
p coerce(2 + 3)
p counted(9)
