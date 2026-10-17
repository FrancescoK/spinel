# Every parameter kind, read through a parameter: positionals, defaults,
# rest, a post-rest positional, keywords with and without a default, the
# keyword rest and the block, in CRuby's order.
def full(a, b = 1, *rest, c, k:, o: 2, **kw, &blk); end
def blk_only(&b); end

def kinds(m) = m.parameters

p kinds(method(:full))
p kinds(method(:blk_only))
