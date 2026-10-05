# A Hash subclass instance read out of a mixed Array is boxed (#7449), and
# it answers as CRuby's does through the boxed path: Hash's methods, reached at run time: the readers, the mutators, the
# iterators and the Enumerable ones; merge and compact answer its class.
# Each probe takes a fresh instance.
class Opts < Hash
  def initialize(src) = (super(); @src = src)
  def label = "opts"
end

def fresh
  pg = Opts.new("x")
  pg[:a] = 1
  pg[:b] = 2
  objs = [pg, [9], {a: 1}, 3]
  objs[0]
end

o = fresh
p o.size
o = fresh
p o.length
o = fresh
p o.empty?
o = fresh
p o.count
o = fresh
p o[:a], o[:zz]
o = fresh
o[:c] = 3; p o
o = fresh
o.store(:c, 3); p o
o = fresh
p o.fetch(:a), o.fetch(:zz, 0)
o = fresh
p o.key?(:a), o.key?(:zz)
o = fresh
p o.include?(:a), o.include?(:zz)
o = fresh
p o.member?(:b)
o = fresh
p o.value?(2)
o = fresh
p o.keys
o = fresh
p o.values
o = fresh
p o.delete(:a); p o
o = fresh
o.each { |k, v| print k, v }; puts
o = fresh
p o.each { }.equal?(o)
o = fresh
p o.map { |k, v| v }
o = fresh
p o.select { |k, v| v > 1 }
o = fresh
p o.reject { |k, v| v > 1 }
o = fresh
m = o.merge(c: 3); p m.class, m
o = fresh
o.merge!(c: 3); p o
o = fresh
p o.update(d: 4).equal?(o)
o = fresh
o[:n] = nil; p o.compact.class, o.compact
o = fresh
p o.min_by { |k, v| v }
o = fresh
p o.sort_by { |k, v| -v }
o = fresh
p o.sum { |k, v| v }
o = fresh
p o.invert
o = fresh
p o.transform_values { |v| v * 10 }
o = fresh
p o.any? { |k, v| v > 1 }
o = fresh
p o.find { |k, v| v == 2 }
o = fresh
p o.dig(:a)
o = fresh
o.clear; p o.size
o = fresh
o.replace({z: 9}); p o
o = fresh
p o.to_a.size
