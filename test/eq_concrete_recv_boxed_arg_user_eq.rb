# A program's == answering something other than a bool makes a == on a
# boxed receiver boxed, since the receiver may be that class; a Float or
# Integer receiver with only a boxed argument is the builtin ==, a bool,
# and an `if` on it tests that bool (ruby/date's inspect compares a Float
# that may be nil with its to_i, boxed under --int-overflow=promote).
class Tag
  def ==(o) = o.is_a?(Tag) ? :same : nil
end

def boxed(x) = x

def check(f, v)
  if f == boxed(v) then "eq" else "ne" end
end

def check_int(i, v)
  if i == boxed(v) then "eq" else "ne" end
end

p check(1.5, 1), check(1.5, 1.5), check(nil, 1), check(1.5, "s"), check(nil, nil)
p check_int(3, 3), check_int(3, 3.0), check_int(3, :x)
p(Tag.new == Tag.new, Tag.new == 1)
v = [Tag.new, 1.5][0]
p(v == Tag.new)
