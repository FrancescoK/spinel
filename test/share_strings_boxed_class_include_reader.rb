# Builtin fallback arms read shared String bytes without losing user method handles.
class A
  def self.include?(value)
    "A:#{value}:#{value.length}"
  end
end
class B
  def self.include?(value)
    "B:#{value}:#{value.length}"
  end
end
class Other
  def include?(value)
    "instance:#{value}"
  end
end
[A, B, Other.new].each do |klass|
  value = +"hello"
  aliased = value
  value << "!"
  p klass.include?(value)
  p aliased
end
