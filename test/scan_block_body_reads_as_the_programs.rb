# A boxed String's scan with a block is one arm of the dispatch over every class
# with a scan of its own. The arm reads its receiver as the builtin String, but
# the block body is the caller's code: a call in it on another boxed value keeps
# the program's classes as owners of the name, as the inference typed it.
class Scanner
  def initialize(s); @s = s; end
  def scan(re)
    @s.scan(re) { |m| yield(*m) }
  end
  def [](pos, len) = @s[pos, len]
end
class Blank
  def initialize(v); @v = v; end
  def empty? = @v
end
def engine(input, regexp)
  pos = 0
  out = []
  input.scan(regexp) do |indicator, code|
    text = input[pos, 1]
    pos += 2
    if text.empty?
      out << :blank
    else
      out << [text, indicator, code]
    end
  end
  out
end
p engine("a<%= x %>b<% y %>", /<%(=)?(.*?)%>/)
p engine(Scanner.new("<% z %><%= w %>"), /<%(=)?(.*?)%>/)
p Blank.new(true).empty?, Blank.new(nil).empty?
