# A tag-like String subclass with an ivar and methods of its own (#7449):
# String's methods on it, the ones that answer the instance (<<, concat,
# the ! methods, insert, prepend, replace) and the ones that answer a plain
# String (upcase, [], +, *, to_s), == both ways, puts and interpolation of
# its bytes, dup keeping the class and ivars, freeze, clone, is_a? and
# case/when, a Hash key, an Array element, and a method taking a String or
# an instance.

class Tag < String
  def initialize(s, kind)
    super(s)
    @kind = kind
  end
  def kind = @kind
  def label = "#{kind}:#{self}"
end
t = Tag.new("div", :block)
p t, t.kind, t.label
p t.length, t.upcase, t.upcase.class, t[0, 2], t[0, 2].class
p t == "div", "div" == t, t.eql?("div"), t.hash == "div".hash
p "x" + t, t + "y", (t + "y").class, t * 2
puts t
puts "<#{t}>"
r = t << "!"
p r.equal?(t), r.class, t
t.concat("a", "b")
p t
p t.upcase!, t, t.class
p t.downcase!.class
p t.sub!("zz", "q")
t.insert(0, "<")
t.prepend("[")
p t
t.replace("span")
p t, t.kind
d = t.dup
d << "X"
p d, d.class, d.kind, t
t.freeze
p t.frozen?, d.frozen?
begin
  t << "z"
rescue => e
  p e.class
end
c = t.clone
p c.frozen?, c.class
p t.is_a?(String), t.instance_of?(String), String === t, Tag === t
case t
when Tag then puts "tag"
when String then puts "string"
end
h = { t => 1 }
p h["span"], h[t]
arr = [t, "plain"]
p arr, arr.map(&:class), arr.join("-")
def show(x) = x.is_a?(Tag) ? "tag #{x.kind}" : "str #{x}"
p show(t), show("s")
v = [t, 1].first
p v.class, v.length
p t.to_s.class, t.to_str.class, String(t).class
p t.split("p"), t.chars.first.class
p t.start_with?("sp"), t.include?("pa"), t =~ /a/
p t.each_char.to_a.length
p "spa#{t}" == "spaspan"
