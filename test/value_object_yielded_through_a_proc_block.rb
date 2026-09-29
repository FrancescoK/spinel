# A small read-only class compiles to a value-type struct. Yielded to a block
# that has to be a real proc (it writes a local outside it, and the receiver
# comes out of an Array), the struct went into the proc call's integer slot
# through a pointer cast, and a block parameter that got no argument defaulted
# to NULL. Neither compiles for a struct.
class Row
  def initialize(v) = @v = v
  def val = @v
end

class Tag
  def initialize(name) = @name = name
  def name = @name
end

class Conn
  def query
    yield Row.new(7)
    nil
  end

  def label
    yield Tag.new("t" + "7")
    nil
  end
end

found = nil
[Conn.new].last.query { |row| found = row.val }
p found

named = nil
[Conn.new].last.label { |tag| GC.start; named = tag.name }
p named

class Pool
  def initialize = @idle = [Conn.new]

  def with
    conn = @idle.pop
    yield conn
  end

  def first_match
    hit = nil
    with { |conn| conn.query { |row| hit = yield(row) } }
    hit
  end
  alias find first_match
end

p Pool.new.find { |row| row.val }

# The same struct, returned by a method called on a poly receiver, seeded
# the dispatch's result temp with NULL.
class Stock
  def initialize = @idle = [Link.new]

  def with
    link = @idle.pop
    yield link
  end

  def first_val
    got = nil
    with { |link| got = yield(link.fetch) }
    got
  end
end

class Link
  def fetch = Row.new(9)
end

p Stock.new.first_val { |row| row.val }
