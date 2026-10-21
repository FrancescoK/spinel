# spinel: gc-stress
# Each implicit conversion has a target separate from the enclosing builtin.
class Parts
  def to_ary = [3, 4]
end
class MoreParts < Parts
  def to_ary = [5, 6]
end
class Parts
  def to_ary = [7, 8]
end

a = [1, 2]
a[0, 1] = Parts.new
p a
a = [1, 2]
a[0, 1] = MoreParts.new
p a
a = [1, 2, 3]
r = (a[1..2] = Parts.new)
p a, r.is_a?(Parts)

class Message < StandardError
  def to_s = :first
end
class Message
  def to_s = :reopened
end
class OwnMessage < Message
  def message = :own
end
p Message.new.message
p OwnMessage.new.message
p Message.new.to_s
