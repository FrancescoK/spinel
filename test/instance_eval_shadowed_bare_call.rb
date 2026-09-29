# A bare call in a block that another class instance_evals types on that
# receiver, even when the method the block is written in answers the name

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
  def transition(x) = (b = Br.new(x); @log << b; b)
end
class Br
  attr_reader :x
  def initialize(x) = @x = x
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
  def transition(opts)
    branches = []
    event(opts[:on]) { branches << transition(opts[:to]) }
    branches.length == 1 ? branches.first : branches
  end
  def event(*names, &)
    @events.context(names, &) if block_given?
    names.each { |n| @events << Ev.new(n) }
  end
end
m = Machine.new do
  transition on: :ignite, to: :idling
end
p m.events.first.log.map(&:x)
