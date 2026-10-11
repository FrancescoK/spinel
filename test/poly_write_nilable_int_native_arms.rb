# A write through a value of several classes, one of whose write methods
# answers nil: the call's Integer answer holds its nil beside the value,
# and the StringIO and IO arms' byte counts go into it as Integers.
require "stringio"

class Sink
  def write(s) = s.empty? ? nil : s.bytesize
end

def put(io, s) = io.write(s)

sio = StringIO.new
[Sink.new, sio, $stdout].each { |io| p put(io, "ab") }
p put(Sink.new, "")
p sio.string
