# Subclasses of StringIO without an initialize, with one that passes its
# arguments on, two deep, and reached through a case, a boxed Array and
# respond_to? (#9269)
require "stringio"
class Plain < StringIO
end
class Named < StringIO
  def initialize(text, tag)
    @tag = tag
    super(text)
  end
  attr_reader :tag
  def label = "#{tag}:#{string}"
end
class Forward < StringIO
  def initialize(text)
    super
  end
end
class Counter < Plain
  def write(s)
    @n = (@n || 0) + 1
    super(s)
  end
  def count = @n
end
p1 = Plain.new
p1.puts "one"
p1 << "two" << "three"
p p1.string, p1.class, p1.is_a?(StringIO), p1.pos
p2 = Plain.new("seed")
p p2.read, p2.eof?
n = Named.new("abc", :t)
p n.label, n.tag, n.read(2), n.gets
f = Forward.new("line1\nline2\n")
f.each_line { |l| p l }
p f.lineno
c = Counter.new
c.write("a")
c.write("b")
p c.string, c.count
r = Plain.new("x\ny\n")
p r.readlines
def describe(io)
  case io
  when Counter then "counter #{io.count}"
  when StringIO then "sio #{io.string.size}"
  else "other"
  end
end
[p1, n, c, StringIO.new("zz")].each { |io| p describe(io) }
all = [p1, n, c, StringIO.new("q")]
all.each { |io| io.rewind; p io.read }
p n.respond_to?(:tag), n.respond_to?(:string)
p Plain.new("x").string.frozen?
