# A product block with a rest parameter takes CRuby's full proc
# distribution of the tuple (q is 1, r is [3]). The product emitters bind
# leading parameters only, and bound q to the whole tuple and r to nil; the
# block is refused at this line instead.
[1, 2].product([3]) { |q, *r| p [q, r] }
