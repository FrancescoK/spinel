# A call whose targets answer a String an instance variable holds (CData's
# value) or a new String (Text's) hands the first on as its handle and the
# second as a String of its own: the new String's method clears the return
# channel, so a handle an earlier call published is not taken for it.
class T
  def initialize(s) = @string = s
  def value = @string.gsub(/x/, "y")
  def raw = @string
end
class CD < T
  def value = @string
end
class E
  def initialize(c) = @children = c
  def get_text
    @children.each { |c| return c if c.is_a?(T) }
    nil
  end
  def text
    t = get_text
    t.nil? ? nil : t.value
  end
end
es = [E.new([CD.new(+"ax")]), E.new([T.new(+"bx")]), E.new([CD.new(+"cx")]), E.new([T.new(+"dx")])]
a = es.map { |e| e.text }
a[0] << "!"
a[1] << "?"
a[3] << "#"
p a
p es.map { |e| e.get_text.raw }
b = es[1].text
b << "%"
p b, es[1].get_text.raw, es[0].text
