# A class's own def of a name answers before an alias of that name a module
# it includes brings: CRuby looks in the class before its modules, whether
# the def comes before or after the include.
module Tr
  def on_b(_n) = "Tr#on_b"
  alias_method :on_a, :on_b
end

class C
  include Tr
  def on_a(_n) = "C#on_a"
  def on_b(_n) = "C#on_b"
  def go = on_a(1)
end
p C.new.on_a(1)
p C.new.go
p C.new.on_b(1)

class Early
  def on_a(_n) = "Early#on_a"
  include Tr
end
p Early.new.on_a(1)

# a superclass's def does not stop the module's alias, which comes first
class P
  def on_a(_n) = "P#on_a"
end
class E < P
  include Tr
end
p E.new.on_a(1)

module Tr2
  def x = "Tr2#x"
  alias y x
end
class F
  include Tr2
  private def y = "F#y"
  def call_y = y
end
p F.new.call_y

# a def of the name in a branch of the class body is the class's own too
class Cond
  include Tr
  if true
    def on_a(_n) = "Cond#on_a"
  end
end
p Cond.new.on_a(1)
