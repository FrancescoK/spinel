# Under-supplied calls raise at runtime in value position, `Class => var`
# bindings in typed-array patterns, hash-pattern **rest / **nil, Method
# objects over builtin receivers, **hash degrading into *args, char-range
# Enumerable methods, and String accumulators in each_with_object.
# spinel: share
def m(a, b) = a + b
begin
  puts m(1)
rescue ArgumentError => e
  puts "caught: #{e.message}"
end
def kw(a:, b:) = a + b
begin
  puts kw(a: 1)
rescue ArgumentError => e
  puts "caught: #{e.message}"
end
case [1, 2]
in [Integer => x, Integer => y]
  p [x, y]
end
case [1, 2]
in [Integer => x, String => y]
  p "wrong"
else
  p "no match ok"
end
h = { a: 1, b: 2, c: 3 }
case h
in {a:, **rest}
  p a
  p rest
end
case { x: 1, y: 2 }
in {x:, **nil}
  p "wrong"
else
  p "nil rest rejects extras"
end
p "hello".method(:upcase).call
p [1, 2, 3].method(:sum).call
p 5.method(:abs).call
mo = "hi".method(:upcase)
p mo.class
p mo.call
def foo(*args); args; end
hh = { x: 1 }
p foo(**hh)
p foo(1, **hh)
def bar(*args, **opts); [args, opts]; end
p bar(**hh)
p ("a".."e").each_slice(2).to_a
p ("a".."e").each_cons(2).to_a
p ("a".."c").map { |s| s * 2 }
p [1, 2, 3].each_with_object(+"") { |x, s| s << x.to_s }
p [1, 2, 3].each_with_object(+"x") { |i, s| s << "-" }
