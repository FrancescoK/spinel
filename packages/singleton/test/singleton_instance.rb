# `include Singleton` gives the class one instance, built on the first
# `instance` call (also from a class method of the class itself) and
# shared by every thread after that.
require "singleton"

class Counter
  include Singleton

  attr_reader :count

  def initialize
    @count = 0
    @lock = Mutex.new
    puts "Counter#initialize"
  end

  def self.bump
    instance.bump
  end

  # the threads' increments are serialized: the test is about the one
  # instance they share, not about a racing `+=`
  def bump
    @lock.synchronize { @count += 1 }
  end
end

class Settings
  include Singleton

  def initialize
    @values = {}
  end

  def [](key)
    @values[key]
  end

  def []=(key, value)
    @values[key] = value
  end
end

puts "before"
threads = 4.times.map { Thread.new { 10.times { Counter.bump } } }
threads.each(&:join)
p Counter.instance.count
p Counter.instance.equal?(Counter.instance)
Settings.instance[:name] = "spinel"
p Settings.instance[:name]
