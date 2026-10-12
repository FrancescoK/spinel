# A program class's own is_a? / kind_of? / instance_of? (activesupport's
# Duration answers for the number it wraps) is the one a call reaches, also
# through a variable that holds other kinds of values. Such a call was the
# builtin class test, which never asked the override: a Duration of 2 was
# not an Integer. And one answering other than true or false (Tag) was
# taken as a C boolean, and the C did not build.
class KqDur
  def initialize(v) = @v = v
  def is_a?(klass) = KqDur == klass || @v.is_a?(klass)
  def kind_of?(klass) = is_a?(klass)
  def instance_of?(klass) = KqDur == klass || @v.instance_of?(klass)
end

class KqTag
  def instance_of?(klass) = klass == KqTag ? :tag : nil
end

[1, "a", nil, [1], {a: 1}, 1.5, :s, KqDur.new(2), KqTag.new].each do |x|
  p [x.is_a?(Integer), x.kind_of?(String), x.instance_of?(Integer), x.instance_of?(KqTag), x.is_a?(KqDur)]
end
