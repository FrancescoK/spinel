# A DSL method that hands its block to another object's instance_eval runs
# that block with self = that object, however deeply the DSL nests.

# 1. nested DSL blocks (event do transition ... end)
class Event1
  attr_reader :name, :branches
  def initialize(name) = (@name = name; @branches = [])
  def transition(h) = @branches << h
end
class Machine1
  attr_reader :events
  def initialize = (@events = [])
  def event(name, &)
    e = Event1.new(name)
    e.instance_eval(&) if block_given?
    @events << e
    e
  end
end
m1 = Machine1.new
m1.instance_eval do
  event :ignite do
    transition parked: :idling
  end
  event :park do
    transition idling: :parked
  end
end
p m1.events.map(&:name)
p m1.events.map(&:branches)

# 2. three levels, DSL call values, several transitions per event
class Branch2
  attr_reader :from, :to
  def initialize(from, to) = (@from = from; @to = to)
end
class Event2
  attr_reader :name, :branches, :log
  def initialize(name) = (@name = name; @branches = []; @log = [])
  def transition(h)
    h.each { |f, t| @branches << Branch2.new(f, t) }
    @branches.size
  end
  def note(s) = (@log << s; s.upcase)
end
class Machine2
  attr_reader :events, :states
  def initialize = (@events = []; @states = [])
  def event(name, &)
    e = Event2.new(name)
    e.instance_eval(&) if block_given?
    @events << e
    e
  end
  def state(*names) = (@states.concat(names); names.size)
  def group(label, &) = (instance_eval(&); label)
end
m2 = Machine2.new
count2 = 0
m2.instance_eval do
  state :parked, :idling
  event :ignite do
    transition parked: :idling
    transition stalled: :stalled, idling: :idling
    x = note "go"
    note x + "!"
  end
  group :shifting do
    event :shift_up do
      transition idling: :first_gear
    end
  end
  e = event :park
  count2 = e.branches.size
end
p m2.events.map(&:name)
p m2.events.map { |e| e.branches.map { |b| [b.from, b.to] } }
p m2.events.first.log
p m2.states
p count2

# 3. attribute readers on self, and a block forwarded through two methods
class Ev3
  attr_reader :log, :name
  def initialize(n) = (@name = n; @log = [])
  def note(s) = (@log << s; self)
end
class Mc3
  def event(n, &) = (e = Ev3.new(n); e.instance_eval(&); e)
  def each_event(names, &) = names.map { |n| event(n, &) }
end
m3 = Mc3.new
r3 = m3.event(:go) do
  note "a"
  note "b"
  p log.size
  p self.name
  p @name
  p log.map(&:upcase)
end
p r3.log
p(m3.each_event([:x, :y]) { note name.to_s }.map(&:log))

# 4. forwarding from a top-level method and from an instance method
class E4; def note(s) = s.upcase; end
def run4(&) = E4.new.instance_eval(&)
run4 { x = note "go"; p x }
class M4; def ev(&) = (e = E4.new; e.instance_eval(&); e); end
M4.new.ev { y = note "hi"; p y }
