# Mutex#synchronize and Monitor#synchronize handed their block as an
# argument (`&block`, a proc in a variable, a lambda) run it under the lock
# and answer its value. They ran nothing and answered nil (#9123).
require "monitor"

M = Mutex.new
MON = Monitor.new

def via_mutex(&block) = M.synchronize(&block)
def via_monitor(&block) = MON.synchronize(&block)
def via_value(&block)
  M.synchronize(&block)
end

via_mutex { puts "Mutex#synchronize" }
via_monitor { puts "Monitor#synchronize" }
p via_value { 42 }

# campfire's ResponseCache#synchronize_render: a Mutex out of an Array
class Cache
  def initialize
    @locks = Array.new(4) { Mutex.new }
    @store = {}
  end

  def synchronize_render(key, &block)
    @locks[key.hash % @locks.length].synchronize(&block)
  end

  def fetch(key)
    synchronize_render(key) { @store[key] ||= "rendered #{key}" }
  end
end
c = Cache.new
p c.fetch("a"), c.fetch("a"), c.fetch("b")

# the block is also read as a value
def counted(&block)
  p block.arity
  M.synchronize(&block)
end
p counted { :inside }

# a proc and a lambda held in variables
pr = proc { M.locked? }
p M.synchronize(&pr)
la = -> { MON.synchronize { :nested } }
p M.synchronize(&la)

# the lock is released when the block raises
begin
  via_mutex { raise "boom" }
rescue => e
  p e.message
end
p M.locked?
