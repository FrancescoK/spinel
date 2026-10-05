# Each line each_line yields is a fresh String; a block parameter that has to
# be a shared handle (the line is stored where an append reaches it) binds a
# fresh handle per line.
class Part
  def initialize = @lines = []
  def <<(line) = (@lines << line; self)
  def lines = @lines
end

part = Part.new
"a\nb\n".each_line { |line| part << line }
part.lines[0] << "!"
p part.lines
"xy".each_char { |ch| part << ch }
part.lines[-1] << "?"
p part.lines
