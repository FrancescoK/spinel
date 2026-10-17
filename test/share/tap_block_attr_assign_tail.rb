# An attribute assignment that ends a tap's block is no value anyone takes:
# tap answers its receiver, so the writer's String is stored, not copied
# out, and the field and the name it came from stay one String (campfire's
# `fragment.replace("div") { |node| node.tap { |n| n.inner_html = ... } }`,
# whose replace takes the block's value).
class Node
  def initialize(h) = @inner = h
  def inner_html = @inner
  def inner_html=(markup)
    @inner = markup.to_s
  end
  def to_s = "<p>" + @inner + "</p>"
  def append(s) = @inner << s
end
class Frag
  def initialize(n) = @nodes = n
  def replace(sel)
    out = +""
    i = 0
    while i < @nodes.size
      node = @nodes[i]
      if sel == "div"
        out = out + (yield node).to_s
      else
        out = out + node.to_s
      end
      i += 1
    end
    out
  end
end
class F
  def initialize(l, f) = (@links = l; @frag = f)
  def unfurled_links = @links
  def run = @frag.replace("div") { |node| node.tap { |n| n.inner_html = unfurled_links.first.to_s } }
end
links = [+"<a>1</a>", +"<a>2</a>"]
nodes = [Node.new(+"x"), Node.new(+"y")]
f = F.new(links, Frag.new(nodes))
p f.run
links.first << "!"
nodes[0].append("?")
p links, nodes.map(&:inner_html)
