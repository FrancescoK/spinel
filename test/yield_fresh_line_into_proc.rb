# A block's parameter that a builtin iterator binds to a String of its own
# each turn (File.foreach, IO#each_line, String#each_line, each_char), handed
# straight to a yield into a proc or Method that appends to it: nothing but
# the proc sees the String grow, so the copy the proc takes behaves as
# CRuby's String does.
require "tmpdir"

path = File.join(Dir.tmpdir, "spinel_yield_fresh_line_#{Process.pid}.txt")
File.write(path, "a\nb\n")

class Lines
  def initialize(path) = @path = path

  def each_line
    File.foreach(@path) { |line| yield line }
    self
  end

  def each_io_line
    File.open(@path) { |f| f.each_line { |l| yield l } }
  end

  def each_char
    File.read(@path).each_char { |ch| yield ch }
  end
end

class Inflated
  def initialize(data) = @data = data

  def each_line
    @data.each_line { |l| yield l }
    nil
  end
end

class Collect
  attr_reader :out
  def initialize = @out = []

  def add(s)
    s << "!"
    @out << s
  end
end

out = []
mark = proc { |s| s << "*"; out << s }
lines = Lines.new(path)
lines.each_line(&mark)
lines.each_io_line(&mark)
lines.each_char(&mark)
Inflated.new("x\ny\n").each_line(&mark)
p out

c = Collect.new
lines.each_line(&c.method(:add))
Inflated.new("z\n").each_line(&c.method(:add))
p c.out
File.delete(path)
