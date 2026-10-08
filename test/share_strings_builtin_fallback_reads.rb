# Builtin arms consume shared arguments while other receivers use user methods.
# spinel: gc-minor
class BuiltinReader
  def include?(value) = "include:#{value}"
  def count(first, second) = "count:#{first}:#{second}"
  def delete(first, second) = "delete:#{first}:#{second}"
  def squeeze(first, second) = "squeeze:#{first}:#{second}"
  def partition(value) = "partition:#{value}"
  def rpartition(value) = "rpartition:#{value}"
  def split(value) = "split:#{value}"
  def unpack1(value) = "unpack1:#{value}"
  def pack(value) = "pack:#{value}"
  def join(value) = "join:#{value}"
  def strftime(value) = "strftime:#{value}"
  def index(value) = "index:#{value}"
  def start_with?(value) = "start_with:#{value}"
  def ==(value) = "equal:#{value}"
  def fetch(value) = "fetch:#{value}"
end
value = +"hello"
aliased = value
value << "!"
["hello!", [1, "hello!"], {1 => 2, "hello!" => true}, BuiltinReader.new].each do |reader|
  p reader.include?(value)
end
["hhhelllo!", BuiltinReader.new].each do |reader|
  first = +"hel"
  second = +"hel"
  first_alias = first
  second_alias = second
  first << "o!"
  second << "o!"
  p reader.count(first, second)
  p reader.delete(first, second)
  p reader.squeeze(first, second)
  p first_alias, second_alias
end
[{1 => 2, "hello!" => true}, BuiltinReader.new].each do |reader|
  p reader.fetch(value)
end
p aliased
separator = +"el"
separator_alias = separator
separator << "l"
["hello!", BuiltinReader.new].each do |reader|
  p reader.partition(separator), reader.rpartition(separator), reader.split(separator)
  p reader.index(separator), reader.start_with?(separator), reader == separator
end
format = +"C"
format_alias = format
format << "*"
["hello!", BuiltinReader.new].each do |reader|
  p reader.unpack1(format)
end
[[65, 66], BuiltinReader.new].each do |reader|
  p reader.pack(format), reader.join(separator)
end
format = +"%"
format_alias = format
format << "Y"
[Time.utc(2020), BuiltinReader.new].each do |reader|
  p reader.strftime(format)
end
p separator_alias, format_alias
class PackedString
  def to_str = "x" * 100
end
format = +"a*"
format_alias = format
format << "a*"
[[PackedString.new, PackedString.new], BuiltinReader.new].each do |reader|
  p reader.pack(format).length
end
p format_alias
