# The changed flag: notify_observers reaches nobody until changed is set,
# clears it once it has notified, and changed(false) takes it back.
require "observer"

class Stock
  include Observable

  attr_reader :price

  def initialize(price)
    @price = price
  end

  def price=(value)
    changed if value != @price
    @price = value
    notify_observers(self, value)
  end
end

class Log
  def initialize
    @lines = []
  end

  def update(stock, value)
    @lines << "price #{value}"
  end

  def lines
    @lines
  end
end

s = Stock.new(10)
p s.changed?
log = Log.new
s.add_observer(log)
s.price = 10
s.price = 12
s.price = 12
s.price = 9
p log.lines

p s.changed?
p s.changed
p s.changed?
p s.changed(false)
p s.changed?
p s.notify_observers(s, 0)
p log.lines.size
s.changed
p s.notify_observers(s, 1)
p s.changed?, log.lines.last
