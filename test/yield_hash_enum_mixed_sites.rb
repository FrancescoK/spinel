# A yield with an Array block and a Hash block: a blockless Enumerable call on
# the yield answers per site. The Hash site's cycle, each_slice and each_cons
# walk the [k, v] pairs as CRuby does, beside the Array site's own.
def cyc
  x = yield.cycle
  p x.class
end
def sl = yield.each_slice(1).to_a
def ec = yield.each_cons(1).to_a

cyc { [1, 2] }
cyc { { a: 1 } }
p sl { [1, 2] }
p sl { { a: 1 } }
p ec { [1, 2] }
p ec { { a: 1 } }
