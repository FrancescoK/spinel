# A Hash subclass whose methods override Hash's and reach them with super:
# keys are taken as Strings, Hash's own methods answer as CRuby's do on a
# subclass instance -- merge and compact an instance of the class, select
# and to_h a plain Hash -- and the instance is a Hash to is_a?, case, ==.
class Opts < Hash
  def initialize(defaults = nil)
    super()
    update(defaults) if defaults
  end
  def [](key) = super(key.to_s)
  def []=(key, value)
    super(key.to_s, value)
  end
  def key?(key) = super(key.to_s)
  def fetch(key, *extras) = super(key.to_s, *extras)
end

o = Opts.new
o[:a] = 1
o["b"] = 2
p o[:a], o["a"], o[:b], o.key?(:b), o.fetch(:a), o.fetch(:zz, 9)
p o.fetch(:zz) { |k| k * 2 }
p o.class, o.size, o
m = o.merge({"c" => 3})
p m.class, m
s = o.select { |k, v| v > 1 }
p s.class, s
p o.compact.class, o.to_h.class, o.to_h
d = o.dup
d[:x] = 10
p d.class, d.size, o.size
case o
when Opts then puts "Opts"
end
p o.is_a?(Hash), o.instance_of?(Hash), Hash === o, o == {"a" => 1, "b" => 2}
o.each { |k, v| puts "#{k}=#{v}" }
o2 = Opts.new({"q" => 5})
p o2, [o2, 1].first.class
f = o.dup.freeze
begin
  f[:z] = 1
rescue FrozenError => e
  puts e.class
end
p f.frozen?, f.clone.frozen?, f.dup.frozen?

class Counter < Hash
  def initialize = super(0)
  def bump(k) = (self[k] += 1)
end
cn = Counter.new
cn.bump(:x); cn.bump(:x); cn.bump(:y)
p cn, cn[:none], cn.default

class Lazy < Hash
  def initialize
    super() { |h, k| h[k] = k.to_s * 2 }
  end
end
lz = Lazy.new
p lz[:ab], lz, lz.default_proc.class
