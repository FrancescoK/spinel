# `x.times { }` (upto, downto, step) answers its receiver. With x boxed and
# the call the value of a block or a method, the receiver was re-read as
# the boxed variable where the call's Integer belongs, and the C did not
# compile ("incompatible type for argument 1 of sp_box_int").

def t
  r = yield
  p r
rescue NoMethodError => e
  puts e.class
end

def tail(v)
  v.times { |i| i }
end

def tail_up(v)
  v.upto(4) { |i| i }
end

src = [3, nil, "s", 1.5]
x = src[0]
t { x.times { |i| i } }
t { x.upto(5) { |i| i } }
t { x.downto(1) { |i| i } }
t { src[1].times { |i| i } }
t { src[3].step(2.0, 0.5) { |f| f } }
p tail(src[0])
p tail_up(src[0])
begin
  tail(src[1])
rescue NoMethodError => e
  puts e.class
end
