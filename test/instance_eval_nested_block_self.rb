# A block made inside an instance_eval block has the receiver as self

class K
  attr_reader :log
  def initialize = @log = []
  def ev(x) = @log << x
  def later(&b) = @saved = b
  def run = @saved.call
end

k = K.new
k.instance_eval { pr = proc { ev 1 }; pr.call; ev 2 }
k.instance_eval { later { ev 3 } }
k.run
p k.log

m = K.new
outer = proc { inner = proc { @log << :in }; inner.call; ev :out }
m.instance_eval(&outer)
p m.log

# the DSL shape: the inner block is kept and later instance_eval'd on
# another object; spinel runs it there or raises NotImplementedError,
# never with the outer receiver as self
class Event
  attr_reader :log
  def initialize = @log = []
  def transition(x) = @log << x
  def context(&) = instance_eval(&)
end
class Machine
  attr_reader :events
  def initialize(&)
    @events = []
    @ctx = []
    instance_eval(&)
  end
  def transition(x) = raise("machine")
  def event(&block)
    @ctx << { block: block }
    e = Event.new
    @events << e
    @ctx.each { |c| e.context(&c[:block]) }
  end
end
r = begin
  Machine.new { event { transition :idling } }.events.map(&:log)
rescue NotImplementedError => e
  e.class
end
p r == [[:idling]] || r == NotImplementedError

# a DSL call with its own block, inside a proc run by instance_eval
class Machine2
  attr_reader :events
  def initialize(&)
    @events = []
    instance_eval(&)
  end
  def event(&)
    e = Event.new
    @events << e
    e.context(&)
  end
end
dsl = proc { event { transition :parked } }
p Machine2.new(&dsl).events.map(&:log)
