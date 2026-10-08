# Class-value arms accept a held shared String for a plain String parameter.
# A mutating parameter keeps the handle, and unrelated concrete parameter
# types remain excluded from the same dispatch.
# spinel: gc-minor
class FirstClassReader
  def self.read(left, right, padding = "x" * 500)
    "first:#{left}:#{right}:#{padding.size}"
  end

  def self.consume(value)
    value << "A"
  end
end

class SecondClassReader
  def self.read(left, right, padding = "y" * 500)
    "second:#{left}:#{right}:#{padding.size}"
  end

  def self.consume(value)
    value << "B"
  end
end

class InstanceReader
  def read(left, right, padding = "z" * 500)
    "instance:#{left}:#{right}:#{padding.size}"
  end

  def consume(value)
    value << "C"
  end
end

class IntegerReader
  def self.read(left, right)
    left + right
  end
end

p IntegerReader.read(2, 3)
[FirstClassReader, SecondClassReader, InstanceReader.new].each do |reader|
  left = +"left"
  right = +"right"
  left_alias = left
  right_alias = right
  left << "!"
  right << "?"
  p reader.read(left, right)
  p reader.read(left, right, "pad" * 100)
  p left_alias, right_alias
  p reader.consume(left)
  p left_alias
  p reader.read("frozen", "literal", "")
end
