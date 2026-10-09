# spinel: share
# spinel: gc-minor
# Class-value returns preserve the argument handle across boxed dispatch.
class FirstReturn
  def self.consume(value)
    value << "A"
  end
end
class SecondReturn
  def self.consume(value)
    value << "B"
  end
end
class InstanceReturn
  def consume(value)
    value << "C"
  end
end
[FirstReturn, SecondReturn, InstanceReturn.new].each do |receiver|
  value = +"start"
  held = value
  result = receiver.consume(value)
  p result.equal?(value)
  result << "?"
  p [result, held]
end
