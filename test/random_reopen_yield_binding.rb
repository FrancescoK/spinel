# Random's, Float's and Symbol's yielding reopenings need a callable proc form
# and their raw self.
# spinel: gc-minor
# spinel: share
$random_default = 4
class Random
  def binding_yield(a = $random_default, *rest, last, key:, optional: $random_default, **kw, &block)
    yield(a.to_s, rest.inspect, last.to_s, key.to_s, optional.to_s, kw.inspect, (block && block.call(:named)).inspect)
  end
  def binding_early(key:)
    return key if key
    yield
  ensure
    puts "ensure"
  end
end
r = Random.new(1)
blk = proc { |*v| v }
p r.binding_yield(*[1, 2, 3], **nil, key: 5, **{"s" => 6}, &blk)
p r.binding_yield(*[3], key: 7) { |*v| v }
p r.binding_early(key: 8) { :unused }
p r.binding_early(key: nil) { :yielded }
begin
  r.binding_yield(*[3], key: 7)
rescue LocalJumpError => e
  puts e.class
end
class Float
  def float_yield(extra = 1.0) = yield((self + extra).to_s)
end
class Symbol
  def symbol_yield(suffix = "!") = yield(to_s + suffix)
  def symbol_self = yield(self)
end
class Integer
  def integer_yield = yield(self)
end
class String
  def string_yield = yield(self)
end
class Array
  def array_yield = yield(self)
end
class Hash
  def hash_yield = yield(self)
end
p 1.5.float_yield { |v| v + "!" }
p 1.5.float_yield(2.0) { |v| v + "!" }
f = 2.5
p f.float_yield { |v| GC.start; v }
p :ab.symbol_yield { |v| v }
p :ab.symbol_self { |v| v.to_s }
p 3.integer_yield { |v| v * 2 }
p "ab".string_yield { |v| v * 2 }
p [1].array_yield { |v| v + [2] }
p({a: 1}.hash_yield { |v| v.size })
class Symbol
  def appended = yield(to_s)
end
class Float
  def appended = yield(to_s)
end
class Random
  def appended = yield(+"r")
end
p :ab.appended { |v| v << "!" }
p 1.5.appended { |v| v << "!" }
p Random.new(1).appended { |v| v << "!" }
class Float
  def own = yield(self)
  def twice = yield(self * 2.0)
end
p 1.5.own { |v| v + 1 }
p (0.0 / 0.0).own { |v| v.nan? }
p Float::INFINITY.own { |v| v.infinite? }
p 2.25.twice { |v| GC.start; v }
# A bare call of a Random method in a Random reopening is a call on self.
class Random
  def three = [yield(rand(1000)), yield(rand(1000)), yield(rand(1000))]
  def sd = yield(seed)
  def by(n) = yield(bytes(n))
  def roll2 = rand(6)
end
srand(1)
first = Random.new(5).three { |v| v }
srand(2)
second = Random.new(5).three { |v| v }
p first == second
p Random.new(5).roll2 == Random.new(5).rand(6)
p Random.new(7).sd { |v| v }
p Random.new(1).by(4) { |v| v.size }
