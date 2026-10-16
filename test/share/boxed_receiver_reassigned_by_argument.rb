# spinel: share
# spinel: gc-minor
# A call on a boxed local (an Array of Integers, or nil) runs on the value Ruby
# read first, whatever its argument assigns the variable: a nil raises
# NoMethodError after the argument ran, and the variable keeps what the
# argument gave it; an Array is the one the call is made on. A boxed String is
# a handle here, so an in-place change an argument makes is seen as well.
def ints(f) = f ? [1, 2] : nil

z = ints(false)
begin
  p z.join((z = ints(true); ","))
rescue NoMethodError
  puts "nme"
end
p z

w = ints(false)
begin
  w.push((w = ints(true); 3))
rescue NoMethodError
  puts "nme"
end
p w

x = ints(true)
p x.join((x = nil; ","))
p x

y = ints(true)
y.push((y = ints(true); 3))
p y

def box(v) = [1, v].last

s = box(+"abc")
s[(s << "d"; 0)] = "Q"
p s

# a store that widens the Array lands in the variable that still holds the
# receiver read first, not in the temp it was held in
def put(h, i, v)
  h[i] = (h = nil if v == 0; v)
  h
end

def put_key(h, s, v)
  h[s.index("b")] = (h = nil if v == 0; v)
  h
end

def put_self(h, i, v)
  h[i] = (h = h; v)
  h
end

p put([1, 2], 0, "y")
p put([1, 2], 0, 2.5)
p put([1, 2], 0, 3)
begin
  put(nil, 0, 3)
rescue NoMethodError
  puts "nme"
end
p put_key([1, 2], "ab", "x")
p put_key([1, 2], "ab", 2.5)
p put_self([1, 2], 0, "y")
p put_self([1, 2], 0, :s)
begin
  put_self(nil, 0, 3)
rescue NoMethodError
  puts "nme"
end
begin
  put_key(nil, "ab", 3)
rescue NoMethodError
  puts "nme"
end
