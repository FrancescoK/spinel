# merge!/update into a Hash literal: nothing else holds the literal, so it
# answers what a merge into a new Hash does, and a hash of another kind is
# folded into one that holds both (a {} default parameter is a Symbol-keyed
# Hash, the bare {} receiver a String-keyed one)
def mk(extra = {})
  {}.merge!(extra)
end
p mk.keys
p mk({ a: 1 })
p mk({ 1 => 2 })

def upd(extra = {}) = {}.update(extra)
p upd({ b: 2 })

def seeded(extra) = { "s" => 1 }.merge!(extra)
p seeded({ t: 2 })

def conflict(extra) = { a: 1 }.merge!(extra) { |_k, old, new| old + new }
p conflict({ a: 10, b: 2 })

def two(a, b) = {}.merge!(a, b)
p two({ "x" => 1 }, { y: [2] })

class Box
  attr_reader :opts

  def initialize(opts = {})
    @opts = {}.merge!(opts)
  end
end
p Box.new.opts
p Box.new({ k: "v" }).opts

r = ({}).merge!({ z: 0 })
r[:w] = 1
p r

DEFAULTS = { "http:" => 1 }
def chained(s = {}) = {}.merge!(DEFAULTS).merge!(s)
p chained.keys
p chained({ x: 2 })

s = Set.new([1])
p s.size

class Opts
  def to_hash = { size: 3 }
end
p({ "a" => 1 }.merge!(Opts.new))
