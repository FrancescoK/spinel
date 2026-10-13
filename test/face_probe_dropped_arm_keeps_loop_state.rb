# A boxed receiver's `times` tries an arm per kind it may be. The Integer
# arm here is dropped -- its block calls a method nothing defines, which is
# refused -- and the probe abandoned it inside the loop it had opened. The
# loop depth stayed raised, and the next method's ensure emitted a
# `continue` with no loop around it, so the C did not build.
class Ed
  def step(n)
    n.times { undo(nil) }
  end

  def guarded
    yield
  ensure
    puts "ensure"
  end
end

begin
  Ed.new.step([0, "x"][1])
rescue NoMethodError => e
  p e.message
end
Ed.new.guarded { p 1 }
