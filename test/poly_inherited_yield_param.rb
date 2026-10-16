# An inherited yielding method called with a block on a boxed receiver: the
# receiver is a parameter typed one class until a module method's self (two
# includers) boxes it, and the dispatch reaches Base#group through its clone
# (#9261).
class Base
  def group(n) = yield
end
class P1 < Base; end
class S1; end

module M
  def run(o) = o.show(self)
end
class P1; include M; end
class S1; include M; end

class Pretty
  def show(q) = q.respond_to?(:group) ? q.group(1) { "shown" } : "no"
end

puts P1.new.run(Pretty.new)
puts Pretty.new.show(S1.new)
