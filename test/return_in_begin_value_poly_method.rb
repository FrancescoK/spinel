# A `return` inside a begin whose value is an Integer leaves the method,
# so its value takes the method's slot: here a poly one (nil or an Integer
# from the pair). The begin's own result temp is the oint the rescue arm
# and the tail feed.
def pair(x)
  return [nil, 3] if x > 0
  ["ab", nil]
end

def f(x)
  begin
    h, err = pair(x)
    return err if err
    h.size
  rescue ArgumentError
    7
  end
end

p f(1)
p f(-1)

def g(x)
  v = begin
    h, err = pair(x)
    return err if err
    h.size
  rescue ArgumentError
    7
  end
  v + 10
end

p g(1)
p g(-1)
