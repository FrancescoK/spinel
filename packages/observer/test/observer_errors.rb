# An observer without the method it is notified through is refused with
# NoMethodError when it is added, and an observable nobody has watched yet
# answers count_observers, delete_observer and delete_observers.
require "observer"

class Quiet
  include Observable
end

class NoUpdate
end

class OnlyRun
  def run(*)
  end
end

q = Quiet.new
p q.count_observers, q.changed?
p q.delete_observer(NoUpdate.new)
p q.delete_observers
p q.notify_observers(1)

begin
  q.add_observer(NoUpdate.new)
rescue NoMethodError => e
  p e.class, e.message
end
begin
  q.add_observer(OnlyRun.new, :update)
rescue NoMethodError => e
  p e.message
end
p q.add_observer(OnlyRun.new, :run)
p q.count_observers
p q.delete_observers
p q.count_observers
