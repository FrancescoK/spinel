# A send whose name is a method's parameter dispatched over the program's
# literals alone, so a caller handing it a computed name (an interpolation
# with to_sym, a split element) raised NoMethodError for a method the
# receiver answers. The parameter now counts as computed when a caller hands
# it one, and the send takes every method the receiver answers, also through
# a parameter passed on to another method.
class Base
  def handle(name) = public_send(name)
  def relay(name) = handle(name)
end

class Child < Base
  def on_open = puts("opened")
  def on_close = puts("closed")
  def show = puts("show")
end

ev = "open"
Child.new.handle("on_#{ev}".to_sym)
Child.new.relay("on_" + "close")

class Controller
  def process(action) = send(action)
  def health = puts("ok")
end
Controller.new.process("health#show".split("#")[0].to_sym)

# a parameter handed only the program's literals keeps its literal arms
class Quiet
  def run(m) = send(m)
  def a = puts("a")
  def b = puts("b")
end
Quiet.new.run(:a)
Quiet.new.run("b")

begin
  Child.new.handle(:missing)
rescue NoMethodError => e
  puts e.class
end
