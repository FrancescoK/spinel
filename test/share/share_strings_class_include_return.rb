# spinel: share
# spinel: gc-minor
# Builtin fallback arms read shared String bytes without losing user method handles.
class A
  def self.include?(value)
    value << "A"
  end
end
class B
  def self.include?(value)
    value << "B"
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
  result = klass.include?(value)
  p result.equal?(value)
  result << "?"
  p result
  p aliased
end
