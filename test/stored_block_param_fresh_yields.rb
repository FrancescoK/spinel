# A block parameter every yield hands a new String -- an interpolation, a
# builtin String method's answer, an IO read, a local only ever assigned
# such, a method answering only such, or a block parameter of the same
# kind -- may be stored into a container whose elements are then mutated:
# nothing else holds the String, so the element is a new handle over it
# (rack's Files::BaseIterator#each, collected by Enumerable#to_a). It was
# refused. A yielded String something else holds, or a frozen literal, is
# refused as before.

require "tmpdir"

class Parts
  include Enumerable

  def initialize(n) = @n = n

  def each
    @n.times do |i|
      yield heading(i)
      each_chunk(i) { |part| yield part }
    end
    yield "--#{@n}--"
  end

  private

  def heading(i) = "h#{i}:"
  def each_chunk(i)
    yield "c" * (i + 1)
  end
end

a = Parts.new(2).to_a
a.each { |s| s << "!" }
p a

# chunks an IO read answers, through a local and another method's block;
# another class's own read does not reach the File's
class Other
  def read(n) = "x" * n
end

class FileChunks
  include Enumerable

  def initialize(path) = @path = path

  def each
    ::File.open(@path, "rb") do |file|
      each_part(file) { |part| yield part }
      yield "--#{@path.size > 0 ? "end" : ""}--"
    end
  end

  private

  def each_part(file)
    while (part = file.read(4))
      yield part
    end
  end
end

path = File.join(Dir.tmpdir, "spinel_fresh_yield_#{$$}.txt")
File.write(path, "abcdefghij")
a = FileChunks.new(path).to_a
a.each { |s| s << "!" }
p a
File.delete(path)
