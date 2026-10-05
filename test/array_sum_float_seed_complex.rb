# A boxed array summed from a Float seed answers a Complex when an element is
# one, as CRuby does: the call is typed boxed, Float or Complex. Typed Float,
# the Complex total could not live in the slot.
p [1.5, Complex(0, 2)].sum(0.0)
p [0.5, Complex(1, 1), 0.25].sum(0.5)
x = [1, 2.5].sum(0.5)
p x, x + 1, x.class
p [1, 2].sum(0.0), [1.0, 2.0].sum(0.0), [].sum(1.5)
