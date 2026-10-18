# The line File.foreach binds is read again after the yield into a proc
# that appends to it: CRuby's line has grown by then, a copy would not have.
class Lines
  def initialize(path) = @path = path

  def each_line
    File.foreach(@path) { |line| yield line; puts line }
  end
end
out = []
mark = proc { |s| s << "!"; out << s }
Lines.new(__FILE__).each_line(&mark)
p out.size
