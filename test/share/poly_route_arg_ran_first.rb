# A String argument that ran ahead into a temp (here before keyword
# arguments) and is handed on as a handle to a boxed receiver's arms takes
# its handle from that temp: re-emitted as a dispatch box, the temp's
# String went into sp_poly_as_strbuf and the C did not compile (campfire's
# `sanitizer.sanitize fragment.to_html, tags: allowed_tags`).
class San
  def sanitize(html, tags: nil) = html.gsub("<", "&lt;") + tags.size.to_s
end
class StaticSan
  def self.sanitize(html) = html
end
class Frag
  def initialize(h) = @h = h
  def to_html = @h
  def add(s) = @h << s
end
class Doc
  def initialize(h) = @h = h
  def to_html = "<doc>" + @h + "</doc>"
end
class Filter
  def initialize(s, f) = (@s = s; @f = f)
  def sanitizer = @s
  def fragment = @f
  def tags = ["a", "b"]
  def call = sanitizer.sanitize fragment.to_html, tags: tags
end
frag = Frag.new(+"<p>x</p>")
sans = [San.new, StaticSan]
frags = [frag, Doc.new("y")]
p Filter.new(sans[ARGV.size], frags[ARGV.size]).call
p Filter.new(sans[ARGV.size], frags[ARGV.size + 1]).call
frag.add("!")
p Filter.new(sans[0], frag).call
