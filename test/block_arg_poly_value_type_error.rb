# `f(&v)` where v is a boxed value, read from a mixed-type source, that
# turns out not to be a Proc, a Method or nil: sp_poly_to_block raised Proc
# composition's "callable object is expected" for every such call, where
# CRuby's &v says "no implicit conversion of Integer into Proc". This is
# the plain-call path (top-level, instance, class method) through
# emit_block_arg_proc / sp_poly_to_block, not instance_exec/instance_eval's.
class Foo; end
def f(&b) = b ? b.call : :none

class Obj
  def m(&b) = b ? b.call : :none
  def self.cm(&b) = b ? b.call : :none
end

def try
  yield
rescue TypeError => e
  p [e.class, e.message]
end

values = [7, 2.5, "s", [1], (1..2), Object.new, Foo.new, true, false]
values.each { |v| try { f(&v) } }

o = Obj.new
values.each { |v| try { o.m(&v) } }

try { Obj.cm(&values[0]) }

pr = proc { :blk }
q = [1, pr][1]
p f(&q)
p f(&(ARGV.empty? ? nil : pr))
p f(&(ARGV.empty? ? pr : nil))
