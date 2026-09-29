# A module or class body's @x is the module object's own ivar: a read in the
# body, or any access inside a block defined there, reaches the same slot
# its class methods see.
module GLib
  class << self
    attr_accessor :logger
  end
  @logger = "LOG"
  H = proc { |a| p [@logger, a] }
  def self.go = H.call(1)
end
GLib.go
GLib.logger = "NEW"
GLib.go

module Counter
  @n = 10
  BUMP = lambda { @n += 1 }
  START = @n
  def self.n = @n
end
Counter::BUMP.call
Counter::BUMP.call
p [Counter::START, Counter.n]

class Registry
  @items = []
  [:a, :b].each { |k| @items << k }
  def self.items = @items
end
p Registry.items

module Cache
  @hits = 0
  FETCH = lambda { @memo ||= "value"; @hits += 1; @memo }
  def self.hits = @hits
end
p [Cache::FETCH.call, Cache::FETCH.call, Cache.hits]

# a proc that becomes a method body reads the instance's ivar
class Widget
  @count = 0
  SHOW = -> { @count }
  define_method(:size, -> { @size })
  define_method(:double) { @size * 2 }
  def initialize = @size = 4
end
p [Widget::SHOW.call, Widget.new.size, Widget.new.double]
