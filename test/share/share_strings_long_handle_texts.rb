# Under --share-strings (#6765), a String mutator on what a method answers
# changes the String the method was given, a bang chain on it reaches that
# String too, and a nil answer raises NoMethodError, however long the
# call's C is. Here an argument is a call to a method that yields, spliced
# in with its block, whose text the line map's `#line` directives make
# longer still. The handle's text was held in fixed buffers, and a call
# whose text did not fit was read another way, so the C differed with and
# without --no-line-map (#9115): the first call below fit without the
# line map and did not build with it.
def rec(s, n) = s
def maybe(f) = f ? +"x" : nil
def total(v)
  yield v
end

v = maybe(true)
rec(v, total(3) { |x|
  x += 0 if x > 0
  x += 1 if x > 1
  x += 2 if x > 2
  x += 3 if x > 3
  x += 4 if x > 4
  x += 5 if x > 5
  x += 6 if x > 6
  x += 7 if x > 7
  x
}).insert(0, "<")
p v
rec(v, total(1) { |x|
  x += 0 if x > 0
  x += 1 if x > 1
  x += 2 if x > 2
  x += 3 if x > 3
  x += 4 if x > 4
  x += 5 if x > 5
  x += 6 if x > 6
  x += 7 if x > 7
  x
}).append_as_bytes("q")
p v
rec(v, total(2) { |x|
  x += 0 if x > 0
  x += 1 if x > 1
  x += 2 if x > 2
  x += 3 if x > 3
  x += 4 if x > 4
  x += 5 if x > 5
  x += 6 if x > 6
  x += 7 if x > 7
  x
}).upcase!.concat("!")
p v
rec(v, total(3) { |x|
  x += 0 if x > 0
  x += 1 if x > 1
  x += 2 if x > 2
  x += 3 if x > 3
  x += 4 if x > 4
  x += 5 if x > 5
  x += 6 if x > 6
  x += 7 if x > 7
  x
}).insert(0, "<")
p v
w = rec(v, total(4) { |x|
  x += 0 if x > 0
  x += 1 if x > 1
  x += 2 if x > 2
  x += 3 if x > 3
  x += 4 if x > 4
  x += 5 if x > 5
  x += 6 if x > 6
  x += 7 if x > 7
  x
}).swapcase!
p v, w.equal?(v)
begin
  rec(maybe(false), total(5) { |x|
    x += 0 if x > 0
    x += 1 if x > 1
    x += 2 if x > 2
    x += 3 if x > 3
    x += 4 if x > 4
    x += 5 if x > 5
    x += 6 if x > 6
    x += 7 if x > 7
    x
  }).upcase!
rescue NoMethodError => e
  p e.class
end
begin
  rec(maybe(false), total(6) { |x|
    x += 0 if x > 0
    x += 1 if x > 1
    x += 2 if x > 2
    x += 3 if x > 3
    x += 4 if x > 4
    x += 5 if x > 5
    x += 6 if x > 6
    x += 7 if x > 7
    x
  }).append_as_bytes("q")
rescue NoMethodError => e
  p e.class
end

