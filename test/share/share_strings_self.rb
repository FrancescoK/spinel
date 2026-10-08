# spinel: int64
# String extension methods keep the receiver when self leaves the body.
module SelfReceiver
  def self.pass(value)
    value << "!"
    value
  end
end

class String
  def receiver_return = self
  def receiver_store
    $stored_receiver = self
    nil
  end
  def receiver_change
    self << "?"
    nil
  end
  def receiver_pass = SelfReceiver.pass(self)
  def receiver_bytes = bytesize
  def receiver_nested = receiver_return
end

s = +"ab"
t = s.receiver_return
p [s.equal?(t), s.object_id == t.object_id]
t << "c"
p [s, t]
s.receiver_store
p [s.equal?($stored_receiver), s.object_id == $stored_receiver.object_id]
$stored_receiver << "d"
p s
s.receiver_change
p s
u = s.receiver_pass
p [s, u, s.equal?(u), s.object_id == u.object_id]
v = s.receiver_nested
v << "z"
p [s, v, s.equal?(v)]
p s.receiver_bytes

class String
  def receiver_queries(other)
    [self.equal?(other), object_id == other.object_id, frozen?]
  end
  def receiver_read_and_return
    p receiver_bytes
    self
  end
  def receiver_default(other = self)
    other << ":"
    other
  end
  def receiver_closure = -> { self }
end
p s.receiver_queries(s)
p s.receiver_read_and_return.equal?(s)
p s.receiver_default.equal?(s)
p s
fn = s.receiver_closure
z = fn.call
z << "*"
p [s, z, s.equal?(z)]

class String
  def receiver_yield
    yield self
    self
  end
  def receiver_deferred_bytes = -> { bytesize }
  def receiver_super = self
  def receiver_bytes_super = bytesize
end
module SelfReceiverLayer
  def receiver_super
    self << "/"
    super
  end
  def receiver_bytes_super
    self << ";"
    super
  end
end
class String
  prepend SelfReceiverLayer
end
w = s.receiver_yield { s << "=" }
p [s, w, s.equal?(w)]
measure = s.receiver_deferred_bytes
s << "~"
p measure.call == s.bytesize
r = s.receiver_super
p [s, r, s.equal?(r)]
p s.receiver_bytes_super
p s

# A boxed receiver and a computed method name reach the same method body.
values = [s, 1]
x = values.first.receiver_return
x << "+"
p [s, x, s.equal?(x)]
name = [:receiver_return].first
y = s.send(name)
y << "-"
p [s, y, s.equal?(y)]

# Object's inherited method takes a box rather than a String receiver.
class Object
  def receiver_parent = self
end
class String
  def receiver_parent
    self << "%"
    super
  end
end
parent_result = s.receiver_parent
p [s, parent_result, s.equal?(parent_result)]
