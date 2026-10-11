# A poly receiver indexed by a Range with a boxed end, in a program where
# a class of its own defines `[]`: the String and Array arms read the
# index as an Integer and raised TypeError for the Range.
class Box
  def [](key)
    "box #{key.inspect}"
  end
end

def pick(i)
  case i
  when 0 then "abcdef"
  when 1 then [1, 2, 3, 4]
  else Box.new
  end
end

# an element of a mixed Array, so a boxed value
def cut(found)
  [found ? 2 : 1, "x"].first
end

[0, 1, 2].each do |i|
  r = pick(i)
  c = cut(i != 1)
  p r[c..]
  p r[..c]
  p r[1]
end
