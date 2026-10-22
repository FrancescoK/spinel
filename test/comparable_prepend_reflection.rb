# Reflection and ordered operators read the same prepend membership fact.
class ReflectionOrder
  def initialize(n) = @n = n
  attr_reader :n
  def <=>(other) = n <=> other.n
end
class ReflectionPre < ReflectionOrder
  prepend Comparable
end
class ReflectionReopen < ReflectionOrder
end
class ReflectionReopen
  prepend Comparable
end
xs = [ReflectionPre.new(1), ReflectionReopen.new(1), 1]
xs.each do |x|
  p [x.respond_to?(:<), x.respond_to?(:clamp)]
end
p ReflectionPre.new(1).respond_to?(:<)
p ReflectionPre.new(1).methods.include?(:between?)
p ReflectionReopen.new(1).respond_to?(:<)
p ReflectionReopen.new(1).methods.include?(:between?)
