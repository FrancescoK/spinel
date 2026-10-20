# Marshal of a StringIO subclass: its object embeds the StringIO and its
# constructor is StringIO's, so it has no row of Marshal's generic table,
# as StringIO has none. Its row named pool symbols such a class never
# defines, and a program that dumped any object did not compile (#9269).
require "stringio"

class Log < StringIO
  def initialize(s)
    super(s)
    @tag = "t"
  end
  attr_reader :tag
end

class Pt
  def initialize(x) = @x = x
  attr_reader :x
end

l = Log.new(+"abc")
p l.read, l.tag
[l, [1, l]].each do |v|
  begin
    Marshal.dump(v)
    puts "dumped"
  rescue TypeError => e
    p e.class
  end
end
p Marshal.load(Marshal.dump(Pt.new(3))).x
