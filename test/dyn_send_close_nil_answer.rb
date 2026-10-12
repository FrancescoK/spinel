# A dynamic send of :close where a program class's close answers nil beside
# a stream's: the builtin arm answers nil into the call's nil slot
class T
  def close(now = false)
    @x = now
    nil
  end
end
def go(o, op, a) = o.__send__(op, a)
def go0(o, op) = o.__send__(op)
p go(T.new, :close, true)
p go(T.new, :close, false)
p go0(T.new, :close)
f = File.open(__FILE__)
begin
  go(f, :close, 1)
rescue ArgumentError => e
  p e.message
end
p f.closed?
p go0(f, :close)
p f.closed?
