# A boxed user call keeps its handle while byte-taking builtin fallbacks read it.
class ClassReader
  def self.index(value) = "index:#{value}"
  def self.rindex(value) = "rindex:#{value}"
  def self.start_with?(value) = "start_with?:#{value}"
  def self.end_with?(value) = "end_with?:#{value}"
  def self.delete(value) = "delete:#{value}"
  def self.partition(value) = "partition:#{value}"
  def self.rpartition(value) = "rpartition:#{value}"
  def self.count(value) = "count:#{value}"
  def self.squeeze(value) = "squeeze:#{value}"
  def self.split(value) = "split:#{value}"
  def self.pack(value) = "pack:#{value}"
  def self.unpack1(value) = "unpack1:#{value}"
  def self.join(value) = "join:#{value}"
  def self.strftime(value) = "strftime:#{value}"
  def self.fetch(value) = "fetch:#{value}"
end
class InstanceReader
  def index(value) = "index:#{value}"
  def rindex(value) = "rindex:#{value}"
  def start_with?(value) = "start_with?:#{value}"
  def end_with?(value) = "end_with?:#{value}"
  def delete(value) = "delete:#{value}"
  def partition(value) = "partition:#{value}"
  def rpartition(value) = "rpartition:#{value}"
  def count(value) = "count:#{value}"
  def squeeze(value) = "squeeze:#{value}"
  def split(value) = "split:#{value}"
  def pack(value) = "pack:#{value}"
  def unpack1(value) = "unpack1:#{value}"
  def join(value) = "join:#{value}"
  def strftime(value) = "strftime:#{value}"
  def fetch(value) = "fetch:#{value}"
end
[ClassReader, InstanceReader.new].each do |reader|
  value = +"hello"
  aliased = value
  value << "!"
  p reader.index(value)
  p reader.rindex(value)
  p reader.start_with?(value)
  p reader.end_with?(value)
  p reader.delete(value)
  p reader.partition(value)
  p reader.rpartition(value)
  p reader.count(value)
  p reader.squeeze(value)
  p reader.split(value)
  p reader.pack(value)
  p reader.unpack1(value)
  p reader.join(value)
  p reader.strftime(value)
  p reader.fetch(value)
  p aliased
end
