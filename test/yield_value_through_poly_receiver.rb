# A yielding method called only through a poly receiver (here the parameter of
# a proc that is stored in an ivar and called from a method) still hands back
# the value its block gave the yield. No call site resolved to the method, so
# the yield's value stayed unknown and a local assigned from it typed as nil
# from its other write. The method then returned nil and the value was lost.
# `conn` comes out of `@idle.pop`, so no typed call gives `found` a type by
# another route.
class Row
  def initialize(v) = @v = v
  def val = @v
end

class Conn
  def query
    yield Row.new(7)
    nil
  end
end

class Pool
  def initialize
    @idle = [Conn.new]
  end

  def with
    conn = @idle.pop
    yield conn
  end

  def first_match
    found = nil
    with { |conn| conn.query { |row| found = yield(row) } }
    found
  end
end

class Endpoint
  def initialize(handler) = @handler = handler
  def call(pool) = @handler.call(pool)
end

p Endpoint.new(proc { |pool| pool.first_match { |row| row.val } }).call(Pool.new)
p Endpoint.new(proc { |pool| pool.first_match { |row| row.val }.nil? }).call(Pool.new)
p Endpoint.new(proc { |pool| pool.first_match { |row| "v#{row.val}" } }).call(Pool.new)
