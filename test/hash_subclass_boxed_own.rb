# A Hash subclass instance read out of a mixed Array is boxed (#7449), and
# it answers as CRuby's does through the boxed path: its own questions: its class and ancestry, is_a?, ===, case, respond_to?,
# dup, its ivars, its own method, send, freeze.
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
p o.class
o = fresh
p o.class.ancestors.first(3)
o = fresh
p o.is_a?(Opts)
o = fresh
p o.kind_of?(Hash)
o = fresh
p o.is_a?(Enumerable)
o = fresh
p o.instance_of?(Hash), o.instance_of?(Opts)
o = fresh
p Hash === o, Opts === o, Enumerable === o
o = fresh
case o; when Opts then puts "opts"; when Hash then puts "hash"; end
o = fresh
p o.respond_to?(:size)
o = fresh
p o.respond_to?(:key?)
o = fresh
p o.respond_to?(:label)
o = fresh
p o.dup.class
o = fresh
p o.dup.instance_variable_get(:@src)
o = fresh
p o.instance_variable_get(:@src)
o = fresh
p o.instance_variables
o = fresh
p o.label
o = fresh
p o.send(:size)
o = fresh
p o.public_send(:keys)
o = fresh
p o.nil?
o = fresh
p o.frozen?
o = fresh
o.freeze; p o.frozen?
