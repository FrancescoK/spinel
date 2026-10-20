# A sum block's String parameter that another name shares (kept in an
# instance variable that is changed in place later) is held as the String
# itself, so each character the iteration hands it is bound as one: plain
# and with a start value, through each_char and with each_with_index's
# index. The binding assigned the bare characters and the C did not build.
class Meter
  def initialize = @last = +""
  attr_reader :last

  def width(text, tab) = text.chars.sum { |ch| @last = ch; ch == "\t" ? tab : 1 }
  def started(text) = text.chars.sum(10) { |ch| @last = ch; ch.size }
  def each_char_sum(text) = text.each_char.sum { |ch| @last = ch; ch == "a" ? 2 : 1 }
  def indexed(text) = text.chars.each_with_index.sum { |ch, i| @last = ch; i }
  def looked_up(text)
    sizes = { "\t" => 4 }
    text.chars.sum { |ch| @last = ch; sizes.fetch(ch, 1) }
  end
  def mark = @last << "!"
end

m = Meter.new
p m.width("\tab", 4)
m.mark
p m.last
p m.started("xyz"), m.last
p m.each_char_sum("bab")
p m.indexed("pqr"), m.last
p m.looked_up("\t\tc")
m.mark
p m.last
p [[1, 2], [3, 4]].sum { |a, b| a * b }
