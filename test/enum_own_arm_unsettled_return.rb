# A name a reopening of Enumerable adds, called on a boxed receiver, is
# dispatched over the classes that define it themselves (the enum_own arm).
# One of those classes answers something inference can never type -- its
# method reads an ivar no code assigns -- and the arm's value used to stay
# unknown for it, so the C seeded the dispatch's slot as an Integer while
# the other arms stored their Strings and Hashes into it. The arm's value
# is the join of the classes whose answers have settled.
module Enumerable
  def as_json(options = nil) = to_a.map { |v| v.as_json(options) }
end

class String
  def as_json(options = nil) = self
end

class Widget
  def initialize(n) = @n = n
  def as_json(options = nil)
    block_given? ? yield({ "n" => @n }) : { "n" => @n }
  end
end

class Gadget
  def as_json(options = nil) = options ? options.size : 42
end

class Ghost
  def as_json(options = nil) = helper(options)
  def helper(o) = @x.foo(o)
end

class Bag
  include Enumerable
  def initialize(*items) = @items = items
  def each(&block) = @items.each(&block)
end

class Runner
  def initialize(target, arguments, block)
    @target = target
    @arguments = arguments
    @block = block
  end
  def invoke(method)
    @target.send(method, *@arguments, &@block)
  end
end

targets = ["str", Widget.new(3), Gadget.new, Bag.new("a", Widget.new(1))]
targets.each do |t|
  p t.as_json
  p t.as_json(only: 1)
  p Runner.new(t, [], nil).invoke(:as_json)
  p Runner.new(t, [{ only: 1, except: 2 }], nil).invoke(:as_json)
end
p Runner.new(Widget.new(5), [], proc { |h| h.keys }).invoke(:as_json)
p Ghost.instance_method(:as_json).arity
