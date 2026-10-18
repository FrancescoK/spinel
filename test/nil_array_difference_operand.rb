# A nil right operand of Array#- and #difference is CRuby's TypeError,
# "no implicit conversion of nil into Array", for a typed Array of any
# element kind, in any position of difference's operand list (#9347). The
# receiver's own nil is the NoMethodError for `-`. The operand slot is filled
# by `setb`, which the nil calls never reach; `seta` fills the receiver.
def raises(label)
  r = yield
  puts "#{label}: #{r.inspect}"
rescue NoMethodError, TypeError => e
  puts "#{label}: #{e.class}: #{e.message}"
end

class IA
  def seta = (@a = [1, 2, 3, 2])
  def setb = (@b = [2])
  def minus = @a - @b
  def diff = @a.difference(@b)
  def diff_first = @a.difference(@b, [1])
  def diff_last = @a.difference([1], @b)
  def diff_empty = @a.difference
  def empty_minus = [] - @b
end
class FA
  def seta = (@a = [1.5, 2.5, 1.5])
  def setb = (@b = [1.5])
  def minus = @a - @b
  def diff = @a.difference(@b)
  def diff_first = @a.difference(@b, [2.5])
  def diff_last = @a.difference([2.5], @b)
end
class SA
  def seta = (@a = ["a", "b", "a"])
  def setb = (@b = ["a"])
  def minus = @a - @b
  def diff = @a.difference(@b)
  def diff_first = @a.difference(@b, ["b"])
  def diff_last = @a.difference(["b"], @b)
end

[IA, FA, SA].each do |k|
  o = k.new
  o.seta
  %i[minus diff diff_first diff_last].each { |m| raises("#{k} #{m}, operand nil") { o.public_send(m) } }
  raises("#{k} minus, receiver nil") { k.new.minus }
  o.setb
  %i[minus diff diff_first diff_last].each { |m| raises("#{k} #{m}") { o.public_send(m) } }
end
o = IA.new
o.seta
raises("IA diff_empty") { o.diff_empty }
raises("IA empty_minus, operand nil") { IA.new.empty_minus }
o.setb
raises("IA empty_minus") { o.empty_minus }
