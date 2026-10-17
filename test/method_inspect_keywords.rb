# Method#inspect writes keywords and the block as CRuby does: `k:`,
# `o: ...`, `&blk`. The location after the parameters is left out here.
def full(a, b = 1, *rest, c, k:, o: 2, **kw, &blk); end
def run(name:, count: 1); end

def shown(m) = m.inspect.sub(/ \S+:\d+>\z/, ">")

puts shown(method(:full))
puts shown(method(:run))
