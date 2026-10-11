# A String subclass instance is its String: String's methods run on it, its
# own methods and ivars stay its class's, and it answers as a String to ==
# , case/when, interpolation and a String argument.
class Tag < String
  attr_reader :kind
  def initialize(s, kind = :plain)
    super(s)
    @kind = kind
  end
  def shout
    upcase + "!"
  end
  def wrap
    "<" + self + ">"
  end
end
t = Tag.new("hi", :em)
p t, t.kind, t.shout, t.wrap
p t.is_a?(String), t.instance_of?(String), t.instance_of?(Tag), Tag.ancestors.include?(String)
p String === t, t.respond_to?(:upcase), t.respond_to?(:kind)
case t
when String then puts "string"
else puts "other"
end
p t == "hi", t.eql?("hi"), "hi" == t, t <=> "ha", t.equal?(t)
puts "x#{t}y"
puts t
p [t, "z"], { t => 1 }["hi"]
u = t.dup
u << "!!"
p u, u.kind, u.class, t
t.upcase!
p t, t.kind
t[0] = "j"
p t
t.gsub!(/I/, "o")
p t
t.replace("new")
p t, t.size
t.clear
p t, t.empty?
v = Tag.new("frozen")
v.freeze
p v.frozen?
begin
  v << "x"
rescue => e
  p e.class
end
w = v.clone
p w.frozen?, w
p "ab" + Tag.new("cd"), Tag.new("b") > "a", Tag.new("x") * 3
p Tag.new("a,b").split(","), Tag.new(" s ").strip, Tag.new("abc").reverse.class
