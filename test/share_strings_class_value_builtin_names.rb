# spinel: gc-minor
# A boxed Class calls its own class method before a colliding builtin.
# The result slot holds the class methods' answers, including different types.
class ClassReader
  def self.read(value) = "read:#{value}:#{value.length}"
  def self.write(value) = "write:#{value}"
  def self.open(value) = "open:#{value}"
  def self.parse(value) = "parse:#{value}"
  def self.load(value) = "load:#{value}"
  def self.new(value) = "new:#{value}"
  def self.[](value) = "index:#{value}"
  def self.fetch_it(value) = "fetch:#{value}"
  def self.name(value = "zero") = "name:#{value}"
  def self.size(value = "zero") = "size:#{value}"
  def self.length(value = "zero") = "length:#{value}"
end

class OtherClassReader
  def self.read(value) = "other:#{value}:#{value.length}"
  def self.write(value) = value.length
  def self.open(value) = "other open:#{value}"
  def self.parse(value) = "other parse:#{value}"
  def self.load(value) = "other load:#{value}"
  def self.new(value) = "other new:#{value}"
  def self.[](value) = "other index:#{value}"
  def self.fetch_it(value) = "other fetch:#{value}"
  def self.name(value = "zero") = value.length + 30
  def self.size(value = "zero") = "other size:#{value}"
  def self.length(value = "zero") = "other length:#{value}"
end

class InheritedClassReader < ClassReader
end

[ClassReader, OtherClassReader, InheritedClassReader].each do |klass|
  value = +"hello"
  aliased = value
  value << "!"
  p klass.read(value)
  p klass.write(value)
  p klass.open(value)
  p klass.parse(value)
  p klass.load(value)
  p klass.new(value)
  p klass[value]
  p klass.fetch_it(value)
  p klass.name(value), klass.name
  p klass.size(value), klass.size
  p klass.length(value), klass.length
  p aliased
end
