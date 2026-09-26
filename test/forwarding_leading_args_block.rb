# `...` forwarded with leading arguments -- `def info(...) = dispatch(:info, ...)`,
# the shape activesupport's BroadcastLogger stamps out per logger method --
# to a callee that takes a block: the forwarder becomes
# `def info(*a, **k, &b) = dispatch(:info, *a, **k, &b)`, so the block
# travels too. (The anonymous `*`, `**` rewrite covered callees without a
# block; a block-taking callee kept the direct model, which has no room for
# leading arguments and refused the call.)
def a(*r, **k, &b) = [r, k, b ? b.call : nil]
def m(...) = a(...)
def n(...) = a(:lead, ...)
class D
  def dispatch(method, *args, **kwargs, &block) = [method, args, kwargs, block ? block.call : nil]
  def info(...) = dispatch(:info, ...)
  def warn(...)
    dispatch(:warn, ...)
  end
end
p m(1, x: 2) { 3 }, n(1, x: 2) { 3 }, m
d = D.new
p d.info("msg"), d.warn("w", level: 1) { :blk }, d.info
