# A kind query with a class held in a variable (`x.is_a?(k)`), on a value
# that may be an instance of a program class defining the query itself
# (activesupport's Duration answers for the number it wraps). The call was
# the builtin class test, which never asked the override: a KqvD wrapping 3
# was not an Integer. Every other value still gets the builtin answer.
class KqvD
  def initialize(v) = @v = v
  def is_a?(klass) = KqvD == klass || @v.is_a?(klass)
  def kind_of?(klass) = is_a?(klass)
  def instance_of?(klass) = KqvD == klass || @v.instance_of?(klass)
end

[Integer, String, Array, KqvD].each do |k|
  [1, "a", [2], nil, :s, KqvD.new(3)].each do |x|
    p [k, x.is_a?(k), x.kind_of?(k), x.instance_of?(k)]
  end
end
