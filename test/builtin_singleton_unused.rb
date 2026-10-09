# spinel: share
# spinel: gc-minor
# An unused singleton definition preserves the builtin's construction and layout.
def Struct.unused_helper = :unused
def Regexp.unused_helper = :unused
def Kernel.unused_helper = :unused
def Warning.unused_helper = :unused
def Enumerator.unused_helper = :unused
def MatchData.unused_helper = :unused
def Complex.unused_helper = :unused
Point = Struct.new(:x)
p Point.new(1).x
KeywordPoint = Struct.new(:x, keyword_init: true)
p KeywordPoint.new(x: 2).x
p Regexp.new("a+").match?("aa")
p Kernel.format("%03d", 5)
p [1, 2].each.to_a
p /a(b)/.match("ab")[1]
p Complex(1, 2) + 1
p Warning.respond_to?(:warn)
p Kernel.respond_to?(:new)

# Native singleton reopenings whose methods are unreachable keep working.
require "ostruct"
require "monitor"
def Mutex.unused_native_helper = :unused
def Encoding.unused_native_helper = :unused
def Queue.unused_native_helper = :unused
def SizedQueue.unused_native_helper = :unused
def ConditionVariable.unused_native_helper = :unused
def OpenStruct.unused_native_helper = :unused
def Monitor.unused_native_helper = :unused
def unused_native_caller
  Queue.unused_native_helper
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
