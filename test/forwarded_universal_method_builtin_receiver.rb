# A method handing its arguments on as a splat (`*, **, &` or `*args`)
# to a method every object has, on a value that may be a program object
# overriding it or a builtin: the builtin answers for the builtin
# (activesupport's DeprecatedConstantProxy#respond_to?).
class Zone
  def respond_to?(name, include_all = false) = name == :zone || super
  def is_a?(k) = k == Zone || super
  def kind_of?(k) = k == Zone || super
  def instance_of?(k) = k == Zone
  def inspect = "Z"
  def to_s = "zone"
  def nil? = false
end

class Proxy
  def initialize(t) = @t = t
  def target = @t
  def respond_to?(*, **, &) = target.respond_to?(*, **, &)
  def kind_of?(*, **, &) = target.kind_of?(*, **, &)
  def instance_of?(*, **, &) = target.instance_of?(*, **, &)
  def is_a?(*, **, &) = target.is_a?(*, **, &)
  def inspect(*, **, &) = target.inspect(*, **, &)
  def to_s(*, **, &) = target.to_s(*, **, &)
  def nil?(*, **, &) = target.nil?(*, **, &)
end

class ArgsProxy
  def initialize(t) = @t = t
  def respond_to?(*args) = @t.respond_to?(*args)
end

[[1, 2], Zone.new, "s", 7].each do |v|
  x = Proxy.new(v)
  p [x.respond_to?(:each), x.respond_to?(:zone), x.respond_to?(:size, true)]
  p [x.kind_of?(Array), x.instance_of?(String), x.is_a?(Integer), x.is_a?(Zone)]
  p [x.inspect, x.to_s, x.nil?]
  p [ArgsProxy.new(v).respond_to?(:size), ArgsProxy.new(v).respond_to?(:zone)]
end
begin
  Proxy.new([1]).respond_to?
rescue ArgumentError => e
  puts e.class
end
