# A local String a block captures lives in its cell: freezing it freezes the
# String the cell holds, and a change in place through the block raises
# FrozenError, as in CRuby. The freeze was emitted on the local's own name,
# which the captured local no longer has, and the C did not build
# (ruby/spec's `a.freeze; -> { a.squeeze! }.should.raise(FrozenError)`).
a = String.new("yellow moon")
a.freeze
f = -> { a.squeeze! }
begin
  f.call
  p :no_error
rescue FrozenError => e
  p e.class
end
p a.frozen?, a

b = String.new("ab")
g = proc { b << "c" }
g.call
b.freeze
begin
  g.call
rescue FrozenError
  p :frozen_after_freeze
end
p b
