# each_line on a value that is a String or an object whose each_line a
# module gives it (webrick parse_header over a socket buffer): the line the
# String arm yields reaches the block as the same boxed parameter the other
# arm binds, also where the block changes it in place.
module Lines
  def each_line
    @lines.each { |l| yield l }
    self
  end
end
class Sock
  include Lines
  def initialize(lines) = @lines = lines
end
def parse(raw)
  out = []
  raw.each_line { |line|
    if /^(\w+):(.*)/ =~ line
      key, value = $1, $2
      value = line
      value.slice!(-1..-1)
      out << [key, value]
    end
  }
  out
end
p parse("a: 1\nb: 2\n")
p parse(Sock.new([+"c: 3\n"]))
