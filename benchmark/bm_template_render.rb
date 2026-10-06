# A small template renderer: each partial appends to the page buffer it is
# handed (an object's ivar), every three-hundredth page is kept, and the kept
# pages get a footer appended to their buffer in place afterwards. The buffer
# a method fills and the ivar that owns it are one String.
class Page
  attr_reader :out
  def initialize = @out = +""
  def tag(name, text) = (@out << "<" << name << ">" << text << "</" << name << ">\n")
end

def render_item(buf, item, i)
  buf << "<li class=\"" << (i.even? ? "even" : "odd") << "\">"
  buf << item[:title] << " - " << item[:price].to_s
  buf << "</li>\n"
end

def render_list(buf, items)
  buf << "<ul>\n"
  items.each_with_index { |it, i| render_item(buf, it, i) }
  buf << "</ul>\n"
  buf
end

items = (0...40).map { |i| { title: "item#{i}", price: i * 3 } }
kept = []
bytes = 0
60_000.times do |n|
  page = Page.new
  page.tag("h1", "Catalog #{n % 7}")
  render_list(page.out, items)
  kept << page if n % 300 == 0
  bytes += page.out.bytesize
end
kept.each_with_index { |pg, i| pg.out << "<footer>" << i.to_s << "</footer>\n" }
puts kept.size
puts bytes
puts kept.sum { |pg| pg.out.bytesize }
