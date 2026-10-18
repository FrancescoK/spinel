# A block parameter yielded straight into an appending proc, bound by a
# File.foreach the program defines itself, which yields a String it keeps.
# Still refused, not silently applied to a copy.
class File
  def self.foreach(path)
    yield LINE
  end
end
LINE = +"kept"
class Reader
  def initialize(path) = @path = path
  def each_line
    File.foreach(@path) { |l| yield l }
  end
end
out = []
mark = proc { |s| s << "*"; out << s }
Reader.new("unused").each_line(&mark)
p out
p LINE
