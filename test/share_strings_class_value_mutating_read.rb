# Class and instance arms bind a mutable String through the same binder.
# A plain String argument also reaches a class method's buffer parameter.
class AppendingClassReader
  def self.read(value)
    value << "A"
  end
end

class OtherAppendingClassReader
  def self.read(value)
    value << "B"
  end
end

class PlainInstanceReader
  def read(value)
    "instance:#{value}"
  end
end

[AppendingClassReader, OtherAppendingClassReader, PlainInstanceReader.new].each do |klass|
  value = +"hello"
  aliased = value
  value << "!"
  p klass.read(value)
  p aliased
  p klass.read("fresh".dup)
end
