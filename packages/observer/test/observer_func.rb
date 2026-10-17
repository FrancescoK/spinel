# add_observer with a method name other than update, observers of several
# classes on one observable, notification in the order they were added, and
# adding the same observer again replacing its method.
require "observer"

class Feed
  include Observable

  def publish(item)
    changed
    notify_observers(item)
  end
end

class Mailer
  def initialize(out)
    @out = out
  end

  def deliver(item)
    @out << "mail #{item}"
  end

  def update(item)
    @out << "mail update #{item}"
  end
end

class Counter
  attr_reader :count

  def initialize
    @count = 0
  end

  def update(item)
    @count += 1
  end
end

out = []
feed = Feed.new
mailer = Mailer.new(out)
counter = Counter.new
p feed.add_observer(mailer, :deliver)
p feed.add_observer(counter)
feed.add_observer(->(item) { out << "lambda #{item}" }, :call)
feed.publish("a")
p out, counter.count
p feed.count_observers

p feed.add_observer(mailer)
p feed.count_observers
feed.publish("b")
p out, counter.count
