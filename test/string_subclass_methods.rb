# Which String methods answer the subclass instance and which a plain String,
# as CRuby 4.0 answers them (#7449), and the shapes around a String subclass:
# a singleton method on an instance, `Class.new(String) do ... end`, a bare
# super with a rest into String#[], an alias taken before the class
# redefines the method, +@ / -@, frozen instances, and an instance read
# where a String is wanted (String.new, Kernel#String, format, join, the
# pattern or separator of a String method).

class N < String
  def initialize(s) = super
end

s = N.new("hello world")
r = {}
%w[upcase downcase capitalize swapcase strip lstrip rstrip chomp chop succ next reverse squeeze
   dup clone to_s to_str itself b scrub -@ +@ to_sym].each do |m|
  r[m] = s.public_send(m).class
end
r["+"] = (s + "x").class
r["x+s"] = ("x" + s).class
r["*"] = (s * 2).class
r["%"] = (N.new("%s") % 1).class
r["[]"] = s[0, 3].class
r["[] range"] = s[0..2].class
r["slice"] = s.slice(1).class
r["sub"] = s.sub("o", "0").class
r["gsub"] = s.gsub("o", "0").class
r["tr"] = s.tr("o", "0").class
r["delete"] = s.delete("o").class
r["center"] = s.center(20).class
r["ljust"] = s.ljust(20).class
r["split"] = s.split(" ").map(&:class)
r["chars"] = s.chars.first.class
r["each_char"] = s.each_char.first.class
r["lines"] = s.lines.first.class
r["partition"] = s.partition(" ").map(&:class)
r["force_encoding"] = s.dup.force_encoding("UTF-8").class
r["<<"] = (N.new("a") << "b").class
r["concat"] = N.new("a").concat("b").class
r["replace"] = N.new("a").replace("b").class
r["insert"] = N.new("a").insert(0, "b").class
r["upcase!"] = N.new("a").upcase!.class
r["upcase! nil"] = N.new("A").upcase!.class
r["String.new"] = String.new(s).class
r["interp"] = "#{s}".class
r["=="] = [s == "hello world", "hello world" == s, s.eql?("hello world"), s.hash == "hello world".hash]
r["inspect"] = s.inspect
r["is_a"] = [s.is_a?(String), s.instance_of?(String), String === s, s.class, s.class.superclass]
r["String(s)"] = String(s).class
r["to_s equal"] = s.to_s.equal?(s)
r["format"] = format("%s", s).class
r["join"] = [s, s].join.class
r["each_char self"] = s.each_char { |ch| ch }.equal?(s)
r.each { |k, v| puts "#{k}: #{v.inspect}" }

f = N.new("cold")
f.freeze
p f.frozen?, f.clone.frozen?, f.dup.frozen?, (+f).frozen?, (+f).class, (-f).equal?(f)
g = N.new("warm")
p (+g).equal?(g), (-g).frozen?, (-g).class, g.frozen?

n = N.new("ab")
def n.shout = upcase + "!"
p n.shout, n.class

Word = Class.new(String) do
  def twice = self * 2
end
w = Word.new("ho")
p w.twice, w.class, w.is_a?(String)

class Wrapped < String
  alias plain_upcase upcase

  def upcase = "<" + plain_upcase + ">"

  def [](*args)
    piece = super
    piece ? "[" + piece + "]" : nil
  end
end
x = Wrapped.new("abc")
p x.upcase, x[0, 2], x[1], x[9]

# an instance as the pattern, separator or operand of a String method is
# read as its bytes, a block-taking gsub's among them; succ!, reverse! and
# scrub! always answer the instance
pat = N.new("lo")
h = +"hello world"
p h.include?(pat), h.split(N.new(" ")), h.gsub(pat) { |m| m.upcase }, h.casecmp?(N.new("HELLO WORLD"))
m = N.new("abc")
p m.succ!.class, m.reverse!.class, m.scrub!.class, m
