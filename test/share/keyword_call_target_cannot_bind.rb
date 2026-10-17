# A call with keywords none of a target's parameters take cannot reach that
# target (ArgumentError), so the target's answer is no value of the call:
# the String Frag#to_html keeps and changes does not join the new Strings
# Node#to_html(pretty:) answers, and the map that holds them is not
# refused (the nokogiri package's NodeSet#to_html in campfire, beside
# ActionText's to_html with no keywords).
class Node
  def initialize(t) = @t = t
  def to_html(pretty: false) = pretty ? "<p>\n" + @t + "\n</p>" : "<p>" + @t + "</p>"
end
class Frag
  def initialize = @html = +""
  def add(s) = @html << s
  def to_html = @html
end
class Set
  def initialize(nodes) = @nodes = nodes
  def to_html(pretty: false) = @nodes.map { |n| n.to_html(pretty: pretty) }.join
end
f = Frag.new
f.add("x")
shown = f.to_html
f.add("!")
set = Set.new([Node.new("a"), Node.new("b")])
out = set.to_html(pretty: ARGV.size > 0)
out << "?"
p out, shown
begin
  Set.new([f]).to_html
rescue ArgumentError => e
  puts e.class
end
