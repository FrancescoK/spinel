# spinel: share
# spinel: gc-minor
# A singleton-class body preserves the builtin instance type and constructor.
class << Struct
  def unused_helper = :unused
end
class << Regexp
  def unused_helper = :unused
end
class << Enumerator
  def unused_helper = :unused
end
class << MatchData
  def unused_helper = :unused
end
class << Complex
  def unused_helper = :unused
end
class << Kernel
  def unused_helper = :unused
end
Point = Struct.new(:x)
p Point.new(3).x
p Regexp.new("b+").match?("bb")
p [3, 4].each.to_a
p /(b)/.match("b")[1]
p Complex(2, 3) + 1
p Kernel.format("%02d", 4)

# Native singleton reopenings whose methods are unreachable keep working.
require "ostruct"
require "monitor"
class << Mutex
  def unused_native_helper = :unused
end
class << Encoding
  def unused_native_helper = :unused
end
class << Queue
  def unused_native_helper = :unused
end
class << SizedQueue
  def unused_native_helper = :unused
end
class << ConditionVariable
  def unused_native_helper = :unused
end
class << OpenStruct
  def unused_native_helper = :unused
end
class << Monitor
  def unused_native_helper = :unused
end
m = Mutex.new
m.synchronize { p :locked }
p Encoding::UTF_8.name
q = Queue.new
q << 1
p q.pop
sq = SizedQueue.new(1)
sq << 2
p sq.pop
p ConditionVariable.new.class
p OpenStruct.new(a: 3).a
Monitor.new.synchronize { p :monitored }
