# A variable holding a String shared with another name, handed in
# parentheses after another statement to a method called on a receiver in
# parentheses (a dispatch over the receiver's classes), is that String: the
# block the method hands it to changes the caller's String, as with
# `K.new.wrap(m)`.
SH = proc { |x| x << "" }
class K
  def each_buf(b) = yield(b)
  def wrap(b) = each_buf(b) { |q| yield q }
end
n = 0
m = +"m"; SH.call(m)
(n += 1; K).new.wrap((n += 1; m)) { |w| w << "!" }
p m, n
