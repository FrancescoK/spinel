# A conditional stored into a shared ivar keeps the selected String,
# in statement and value position, including an optional parameter.
$cnd = true
s = +"abc"
@t = ($cnd ? s : +"x")
@t << "!"
p s

class Banner
  attr_reader :text
  def initialize(text = nil)
    @text = text || +"default"
  end
  def reset(text)
    value = (@text = $cnd ? text : +"unused")
    value << "?"
  end
end
b = Banner.new(s)
b.text << "+"
p s
b.reset(s)
p s
p b.text
fresh = Banner.new
fresh.text << "!"
p fresh.text
