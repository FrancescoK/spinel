# A Singleton's `initialize` can wait on another thread that builds a
# different Singleton's instance: each class builds under its own lock.
require "singleton"

class Clock
  include Singleton

  def initialize
    puts "Clock#initialize"
  end
end

class Service
  include Singleton

  attr_reader :clock

  def initialize
    @clock = Thread.new { Clock.instance }.value
    puts "Service#initialize"
  end
end

p Service.instance.clock.equal?(Clock.instance)
