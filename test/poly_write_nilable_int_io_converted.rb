# The same nil-capable write answer, with an IO given an Integer, which it
# converts to a String: its byte count goes into the answer as an Integer.
class Counter
  def write(n) = n == 0 ? nil : 1
end

def put(io, n) = io.write(n)

[Counter.new, $stdout].each { |io| p put(io, 12) }
p put(Counter.new, 0)
