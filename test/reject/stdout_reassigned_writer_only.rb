# An object with only a write stored into $stdout: Ruby's bare puts reaches
# Kernel#puts on it, which writes each line through that write. The call
# through $stdout has no such fallback yet, so the bare puts is refused
# rather than raising NoMethodError where Ruby prints.
class Sink
  attr_reader :buf
  def initialize = @buf = +""
  def write(*a) = (a.each { |s| @buf << s.to_s }; a.size)
end
s = Sink.new
$stdout = s
puts "x"
$stdout = STDOUT
p s.buf
