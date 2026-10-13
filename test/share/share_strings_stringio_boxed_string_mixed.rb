# Flag-only. A boxed receiver's #string that reaches a StringIO beside a
# class with a #string of its own, which answers its ivar's String: each
# answers its own String, not a copy, changed through the answer, through a
# variable, an Array's elements or a block's.
require "stringio"
class Own
  def initialize; @s = +"own"; end
  def string
    @s << ""
  end
end
o = [Own.new, StringIO.new(+"x")][1]
tk = o.string
tk << "-after"
p o.string, o.read
[Own.new, StringIO.new(+"x"), StringIO.new(+"y")].each do |e|
  t = e.string
  t << "+"
  p e.string
end
os = [Own.new, StringIO.new(+"x")]
ts = os.map { |e| e.string }
ts.each { |t| t << "#" }
os.each { |e| p e.string }
