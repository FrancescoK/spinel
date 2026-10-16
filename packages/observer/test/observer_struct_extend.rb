# Observable mixed into a Struct and extended onto one object, with a proc
# as the observer through :call.
require "observer"

Point = Struct.new(:x) do
  include Observable

  def move(dx)
    self.x += dx
    changed
    notify_observers(x)
  end
end

pt = Point.new(1)
pt.add_observer(proc { |v| puts "moved to #{v}" }, :call)
pt.move(2)
pt.move(-5)
p pt.count_observers, pt.x

class Plain
end

o = Plain.new
o.extend(Observable)
o.add_observer(->(*a) { p a }, :call)
o.changed
o.notify_observers(1, 2)
p o.changed?, Plain.new.respond_to?(:add_observer)
