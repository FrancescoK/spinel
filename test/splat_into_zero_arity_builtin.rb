# A builtin that takes no argument, called with a splat (a delegator
# forwarding *args): an empty splat is the plain call, and a non-empty one
# is the arity error, on a typed or a boxed receiver.
def f(a, *args) = a.size(*args)
def g(h, *args) = h.keys(*args)
def e(s, *args) = s.empty?(*args)
p f([1, 2]), f([1, :x]), f("abc"), f({a: 1})
p g({a: 1}), e(""), e([1])
begin
  f([1], 2)
rescue ArgumentError => ex
  p ex.message
end
