# A block handed on as `&block` through a poly dispatch whose default arm
# also serves a Class value (the module's own class method) is made into a
# proc inside that arm. The proc's body is a function of its own: its calls
# on boxed receivers keep the program's classes as owners of their names,
# as the inference typed them, rather than the arm's builtin-only reading.
class Backend
  def initialize(h); @h = h; end
  def keys = @h.keys
  def values = @h.values
  def empty? = @h.empty?
  def size = @h.size
end
class Instrumenter
  def initialize(id); @id = id; end
  def instrument(name, payload = {})
    payload[:id] = @id
    yield payload if block_given?
  end
end
class Fanout
  def listening?(name) = name != "quiet"
end
STATE = {}
module Notifications
  class << self
    def notifier = (@notifier ||= Fanout.new)
    def instrumenter
      STATE[:inst] ||= Instrumenter.new(1)
    end
    def instrument(name, payload = {}, &block)
      if notifier.listening?(name)
        instrumenter.instrument(name, payload, &block)
      else
        yield payload if block_given?
      end
    end
  end
end
def by_keys(coll)
  coll.each_with_object([{}, []]) do |item, (hash, ordered)|
    ordered << item
    hash[item] = item.to_s
  end
end
def render(name, coll)
  Notifications.instrument(name, count: coll.size) do |payload|
    keyed, ordered = by_keys(coll)
    ks = keyed.keys
    vs = keyed.values
    rest = keyed.reject { |k, _| k == 1 }.values
    e = rest.empty? ? [] : rest
    p [payload, ks, vs, e, ordered]
  end
end
render("loud", [1, 2, 3])
render("quiet", [1])
p Backend.new({ a: 1 }).keys
p Backend.new([3, 4]).size
HOLDER = [Notifications]
p HOLDER.size
