# A subclass of StringIO is a StringIO with its own instance variables and
# methods: super reaches the native constructor and methods, and a boxed
# one dispatches on its own class (#9269; console's Terminal::Buffer)
require "stringio"
class Buffer < StringIO
  def initialize(prefix = nil)
    @prefix = prefix
    super()
  end
  attr :prefix
  def puts(*lines, prefix: @prefix)
    lines.each do |line|
      self.write(prefix) if prefix
      super(line)
    end
  end
  alias << puts
end
b = Buffer.new("| ")
b.puts("a", "b")
b << "c"
print b.string
p b.prefix, b.is_a?(StringIO), b.class, b.pos, b.string.size
c = Buffer.new
c.puts "x"
c.write "y", "z"
p c.string, c.prefix
def emit(io) = io.puts("via")
emit(b)
s = StringIO.new
emit(s)
p b.string.lines.last, s.string
[b, s].each { |io| io.print "!"; p io.string.size }
p b.inspect.sub(/0x\h+/, "X")
