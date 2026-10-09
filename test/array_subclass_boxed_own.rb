# spinel: share
# An Array subclass instance read out of a mixed Array is boxed (#7449), and
# it answers as CRuby's does through the boxed path: its own questions: its class and ancestry, is_a?, ===, case, respond_to?,
# dup, its ivars (read and written), its own method, send, method, freeze.
# Each probe takes a fresh instance.
class Page < Array
  def initialize(src) = (super(); @src = src)
  def label = "page"
  def src = @src
end

def fresh
  pg = Page.new("x")
  pg << 1 << 2
  objs = [pg, [9], {a: 1}, 3]
  objs[0]
end

o = fresh
p o.class
o = fresh
p o.class.ancestors.first(3)
o = fresh
p o.is_a?(Page)
o = fresh
p o.kind_of?(Array)
o = fresh
p o.is_a?(Enumerable)
o = fresh
p o.instance_of?(Array), o.instance_of?(Page)
o = fresh
p Array === o, Page === o, Enumerable === o
o = fresh
case o; when Page then puts "page"; when Array then puts "array"; end
o = fresh
case o; when Array then puts "array"; when Page then puts "page"; end
o = fresh
p o.respond_to?(:size)
o = fresh
p o.respond_to?(:push)
o = fresh
p o.respond_to?(:label)
o = fresh
p o.dup.class
o = fresh
p o.instance_variable_get(:@src)
o = fresh
p o.instance_variables
o = fresh
p o.label
o = fresh
p o.send(:size)
o = fresh
p o.public_send(:first)
o = fresh
p o.method(:size).call
o = fresh
p o.then { |x| x.size }
o = fresh
p o.nil?
o = fresh
p o.frozen?
o = fresh
o.freeze; p o.frozen?
o = fresh
p o.instance_variable_set(:@src, "y"), o.instance_variable_get(:@src), o.src
o = fresh
o.instance_variable_set("@src", nil)
p o.src, o.instance_variable_defined?(:@src), o.instance_variables
o = fresh
o.instance_variable_set(:@src, "w")
p o.dup.src
o = fresh
o.freeze
begin
  o.instance_variable_set(:@src, "q")
rescue => e
  p e.class
end
p o.src
