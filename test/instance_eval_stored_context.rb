# A DSL block kept in a context hash and handed to a poly receiver's
# context runs as the one class whose context instance_evals it

class Matcher
  def initialize(names) = @names = names
  def matches?(n) = @names.include?(n)
end
class Ev
  attr_reader :name, :log
  def initialize(name) = (@name = name; @log = [])
  def context(&)
    instance_eval(&)
  end
  def transition(x) = @log << x
end
class St
  attr_reader :name
  def initialize(name) = @name = name
  def context(&) = raise(NotImplementedError, "state block")
end
class Coll
  def initialize = (@nodes = []; @contexts = [])
  def context(names, &block)
    nodes = Matcher.new(names)
    @contexts << { nodes: nodes, block: block }
    @nodes.each { |node| node.context(&block) if nodes.matches?(node.name) }
  end
  def <<(node)
    @nodes << node
    @contexts.each { |ctx| node.context(&ctx[:block]) if ctx[:nodes].matches?(node.name) }
    self
  end
  def first = @nodes.first
end
class Machine
  attr_reader :events, :states
  def initialize(&)
    @events = Coll.new
    @states = Coll.new
    @states << St.new(:parked)
    instance_eval(&)
  end
  def transition(x) = raise("machine transition")
  def event(*names, &)
    @events.context(names, &) if block_given?
    names.each { |n| @events << Ev.new(n) }
  end
end
m = Machine.new do
  event :ignite do
    transition :idling
  end
end
p m.events.first.log
