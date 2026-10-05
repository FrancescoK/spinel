# A String subclass instance read out of a mixed Array is boxed (#7449), and
# it answers as CRuby's does through the boxed path: its own questions: its class and ancestry, is_a?, ===, case, respond_to?,
# dup, its ivars, its own method, send, freeze.
# Each probe takes a fresh instance.
class Buf < String
  def initialize(src) = (super("ab"); @src = src)
  def label = "buf"
end

def fresh
  pg = Buf.new("x")
  objs = [pg, [9], {a: 1}, 3]
  objs[0]
end

o = fresh
p o.class
o = fresh
p o.class.ancestors.first(3)
o = fresh
p o.is_a?(Buf)
o = fresh
p o.kind_of?(String)
o = fresh
p o.is_a?(Comparable)
o = fresh
p o.instance_of?(String), o.instance_of?(Buf)
o = fresh
p String === o, Buf === o
o = fresh
case o; when Buf then puts "buf"; when String then puts "string"; end
o = fresh
p o.respond_to?(:size)
o = fresh
p o.respond_to?(:upcase)
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
p o.nil?
o = fresh
p o.frozen?
o = fresh
o.freeze; p o.frozen?
