# Fresh and boxed receivers stay rooted while arguments allocate or rebind.
class String
  def receiver_append(part)
    self << part
    self
  end
  def receiver_keep = self
end

def receiver_fresh
  +"fresh"
end

def receiver_payload
  GC.start
  +"!"
end

p receiver_fresh.receiver_append(receiver_payload)
p [receiver_fresh, 1].first.receiver_append(receiver_payload)
s = +"old"
alias_s = s
result = s.receiver_append((s = +"new"; receiver_payload))
p [s, alias_s, result, result.equal?(alias_s)]

bytes = [65, 0, 255].pack("C*")
other = bytes.receiver_keep
other << "Z"
p [bytes.bytes, other.bytes, bytes.equal?(other)]
p other.encoding.name

frozen_string = "ice"
p frozen_string.receiver_keep.frozen?
begin
  frozen_string.receiver_append(receiver_payload)
rescue FrozenError
  puts "frozen"
end
