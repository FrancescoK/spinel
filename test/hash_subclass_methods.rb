# What Hash's methods answer on a Hash subclass instance (#7449), method by
# method as CRuby 4.0 answers: the mutators and the walks given a block
# answer the instance; merge and compact a new instance of its class, a copy
# holding the ivars and the default; to_h a plain Hash with the default;
# select, reject, invert, transform_* plain Hashes; the Enumerable walks
# plain Arrays. X.new(default) and X.new { } keep the default value and
# proc, X[...] takes a Hash, pairs or keys and values, and dup / clone copy
# the entries, the ivars and the default, running initialize_copy.
class O < Hash
  attr_accessor :tag
  def initialize_copy(o)
    super
    puts "init_copy"
  end
end
o = O.new; o.tag = 1; o[:a] = 1; o.default = 3
m = o.merge(b: 2); p [m.class, m.tag, m, m.default]
c = o.compact; p [c.class, c.tag, c.default]
d = o.dup; p [d.class, d.tag, d, d.default]
s = o.select { true }; p [s.class, s.default]
r = o.reject { false }; p [r.class, r.default]
t = o.to_h; p [t.class, t.default, t.equal?(o)]
p o.to_hash.class, o.to_hash.equal?(o)
p o.update(z: 26).class, o.merge!(y: 25).equal?(o), o.delete(:y), o.delete(:z)
p o.each { }.class, o.each_pair { }.class, o.keep_if { true }.class, o.delete_if { false }.class
p o.reject! { false }, o.select! { true }, o.compact!
p o.invert.class, o.transform_values { 1 }.class, o.transform_keys(&:to_s).class
p o.min_by { |k, v| v }, o.sort_by { |k, v| v }.class, o.map { |k, v| k }, o.count
p o.sum([]), o.find { true }, o.each_with_object([]) { |(k, v), a| a << k }
p o.filter_map { |k, v| k }, o.group_by { |k, v| v }.class, o.partition { true }.class
p o.any? { |k, v| v == 1 }, o.key?(:a), o.fetch(:a), o.dig(:a), o.values_at(:a), o.keys, o.size
p o.first, o.to_a, o.length, o.empty?, o.include?(:a), o.value?(1), o.key(1)
p O[a: 1].class, O[[[:x, 1]]], O[:p, 1, :q, 2], O[{"s" => 2}].class, O[].size
q = O.new(4); p q[:none], q.default
w = O.new { |h, k| h[k] = k.to_s }; p w[:z], w, w.default_proc.nil?
e = w.merge({}); p e[:new], e.class
p Hash(o).equal?(o)
o.freeze
p o.frozen?
begin; o[:x] = 1; rescue => ex; p ex.class; end
begin; o.tag = 2; rescue => ex; p ex.class; end
f = o.clone; p f.frozen?, f.class
g = o.dup; p g.frozen?; g[:x] = 9; p g
h = o.clone(freeze: false); p h.frozen?
