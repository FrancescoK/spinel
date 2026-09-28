# A receiverless call to a yielding method inside an instance_eval block
# inlines it on the receiver

class Machine
  attr_reader :events

  def initialize(&)
    @events = []
    instance_eval(&)
  end

  def event(name)
    @events << name
    yield if block_given?
  end

  def count = yield(@events.size)
end

m = Machine.new do
  event(:ignite) { @events << :body }
end
p m.events

n = Machine.new do
  event(:park)
  event(:idle) { event(:nested) }
end
p n.events
p(n.instance_eval { count { |k| k * 10 } })

dsl = proc { event(:shift) { @events << :up } }
p Machine.new(&dsl).events
