# send(:name, ...) with a literal name nothing defines raises NoMethodError
# where it runs, as CRuby does; a body that never runs it builds. Refused,
# it also cost the boxed receiver's arm around it: `n.times { ... }` on an
# Integer n raised NoMethodError for times, and the abandoned loop left a
# `continue` in the next method's ensure, so the C did not build.
class Ed
  def step(n)
    n.times { send(:undo, nil) }
  end

  def try_public(x)
    public_send(:redo, x)
  end

  def guarded
    yield
  ensure
    puts "ensure"
  end
end

Ed.new.step(ARGV[0] ? "x" : 0)
Ed.new.guarded { p 1 }
begin
  Ed.new.step(1)
rescue NoMethodError => e
  p e.message
end
begin
  Ed.new.try_public(2)
rescue NoMethodError => e
  p e.message
end
