def k(o)
  p o.is_a?(Array), o.kind_of?(Array), Array === o, o.instance_of?(Array), o.class, o.is_a?(Range), o.is_a?(Enumerable)
  c = [Array, Range, Proc, Hash].find { |x| o.is_a?(x) }
  p c
  case o
  when Array then p :arr
  when Range then p :rng
  when Proc then p :prc
  else p :other
  end
end
k(1..2)
k([1, 2])
k("a".."b")
k({a: 1})
k(-> { 1 })
k(1...)
def h(o); n = 0; o.cycle(2) { n += 1 }; n; end
p h(1..2)
p h([1, 2])
p h("a".."c")
p h({a: 1})
