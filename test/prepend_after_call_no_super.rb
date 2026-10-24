# A later prepend whose methods do not call super, one of them yielding:
# before the prepend runs, the calls reach the class's own methods, the
# block handed on to the one that yields, and after it the module's
# (campfire's BoundedJbuilderFragments, #9982).
class Cache
  def initialize = @store = {}
  def read(key) = fetch_from(key)
  def write(key, value) = store_into(key) { value }
  def fetch_from(key) = "plain:" + key
  def store_into(key) = (@store[key] = yield)
  def dump = @store.inspect
end
module Bounded
  def fetch_from(key) = "bounded:" + key
  def store_into(key) = (@store[key] = "[" + yield + "]")
end
c = Cache.new
p c.read("a")
c.write("x", "1")
p c.dump
class Cache
  prepend Bounded
end
p c.read("a")
c.write("y", "2")
p c.dump
