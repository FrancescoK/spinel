# `Mod[k] ||= v` where `[]` and `[]=` are class-level methods of a module or
# class (`class << self; def [](key)`), activesupport's IsolatedExecutionState
# store: the index-or-write rewrite covered an instance receiver only, and
# a constant receiver was refused. The constant's own `[]` / `[]=` are the
# same `M[k] || (M[k] = v)` rewrite; `&&=` and `op=` alike.
module State
  class << self
    def [](key) = store[key]
    def []=(key, value)
      store[key] = value
    end
    def store = (@store ||= {})
  end
end
class Counter
  def self.[](k) = (@c ||= Hash.new(0))[k]
  def self.[]=(k, v)
    (@c ||= Hash.new(0))[k] = v
  end
end
def start(h)
  stack = (State[:stack] ||= [])
  stack << h
  stack.size
end
p start(1), start(2)
p State[:stack]
State[:flag] = true
State[:flag] &&= :on
p State[:flag]
Counter[:x] += 2
Counter[:x] += 3
p Counter[:x]
