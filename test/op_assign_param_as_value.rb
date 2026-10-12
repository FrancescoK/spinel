# An operator assignment used as a value, on an Integer parameter whose
# addend may be another type
class Span
  def set(first, last)
    @first = first
    @last = last
    self
  end
  def to_s = "#{@first}..#{@last.inspect}"
end

def step(index, small)
  len = if small
    index += 1
    2
  else
    "far"
  end
  Span.allocate.set(index, index += len)
end

puts step(0, true)
puts Span.allocate.set(0, nil)
puts Span.allocate.set(0, "y")

def pick(far) = far ? "far" : 3
def scale(x, far)
  [x, x += pick(far)]
end
p scale(1.5, false)

# an addend that is a Float or a String at run time
def bump(i, by)
  [i, i += by]
end
p bump(0, 2.5)
begin
  bump(0, "s")
rescue TypeError => e
  p e.class
end
def total(n, extra)
  n += extra
  n
end
p total(3, 2.5)
