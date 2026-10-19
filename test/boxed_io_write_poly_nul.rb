# An IO read out of an Array beside a nil is boxed, and so is an operand
# whose class is only known at run time. write, &.write and << through such
# an IO write a String operand with its own byte count, past an embedded NUL,
# whether the String is shared (changed with <<) or not, and still write
# any other operand's to_s.

def frame(type, body)
  out = "".b
  out << [type, body.bytesize].pack("nn")
  out << body
  out
end

class Link
  def initialize(conn)
    @conn = conn
  end

  def deliver(bytes)
    @conn.write(bytes)
  end

  def maybe(bytes)
    @conn&.write(bytes)
  end

  def push(bytes)
    @conn << bytes
  end
end

r, w = IO.pipe
ends = [w, nil]
link = Link.new(ends.first)
p link.deliver(frame(0x0113, "Jayang".b))
p link.deliver("Guui\0Station".b)
p link.deliver(7)
p link.deliver(nil)
p link.maybe(frame(0x0104, "Kondae".b))
p link.maybe(:ICN)
link.push(frame(0x0111, "GMP".b))
link.push("Han\0River".b)
link.push(9)
p Link.new(ends.last).maybe("Achasan")
w.close
p r.read.bytes
