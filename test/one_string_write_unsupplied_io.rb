# A String local written to an io whose `= nil` default no call supplies
# (a `dump(a, b)` of another class keeps it unseeded): the io turns poly
# only after inference, a user `write(*parts)` then stores the local as its
# handle, and the arm for an io known only at run time writes its bytes.
class Sink
  def write(*parts) = parts.size
end

def dump(obj, io = nil)
  text = obj.to_s
  return text if io.nil?
  io.write(text)
  io
end

class Pair
  def dump(a, b) = a + b
end

p Sink.new.write("a", "b")
puts dump(12)
p Pair.new.dump(1, 2)
