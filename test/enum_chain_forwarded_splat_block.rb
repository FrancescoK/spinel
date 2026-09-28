# A block (and an anonymous or named splat) forwarded into a block
# iterator on an Enumerator: the splat can only be empty, and the call's
# value is what the iterator answers.

def fm(a, *, &) = a.each_with_index.map(*, &)
def fr(a, *r, &b) = a.each_with_index.map(*r, &b)
def fsel(a, *, &) = a.each_with_index.select(*, &)
def feach(a, *, &) = a.each_with_index.each(*, &)
def fwi(a, *, &) = a.each.with_index(1).map(*, &)
def fh(h, *, &) = h.each_with_index.map(*, &)

p fm([5, 6]) { |x, i| x * i }
p fr([5, 6]) { |x, i| x + i }
p fsel([5, 6, 7]) { |x, i| i > 0 }
p feach([5, 6]) { |x, i| x * i }
p fwi([5, 6]) { |x, i| x * i }
p fh({a: 1, b: 2}) { |(k, v), i| "#{k}#{v}#{i}" }

# the forwarded call as the method's value, without a splat
def fewo(a, &b)
  a.each_with_index.each_with_object([], &b)
end
p fewo([5, 6]) { |(x, i), acc| acc << x + i }

def fewo_anon(a, &) = a.each_with_index.each_with_object([], &)
p fewo_anon([5, 6]) { |(x, i), acc| acc << x * i }
