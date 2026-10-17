# Observers added, notified with any arguments, deleted one by one and all at
# once, as ruby/observer's own test drives them.
require "observer"

class Ticker
  include Observable

  def tick(*args)
    changed
    notify_observers(*args)
  end
end

class Watcher
  attr_reader :seen

  def initialize(ticker)
    @seen = []
    ticker.add_observer(self)
  end

  def update(*args)
    @seen << args
  end
end

ticker = Ticker.new
p ticker.count_observers
w1 = Watcher.new(ticker)
p ticker.count_observers
ticker.tick("test", 123)
w2 = Watcher.new(ticker)
p ticker.count_observers
ticker.tick(42)
p w1.seen, w2.seen
p ticker.delete_observer(w1).inspect
p ticker.count_observers
ticker.tick(:cats)
p w1.seen, w2.seen
ticker.tick
p w2.seen.last
ticker.delete_observers
p ticker.count_observers
ticker.tick("nope")
p w1.seen, w2.seen
p Observable::VERSION
