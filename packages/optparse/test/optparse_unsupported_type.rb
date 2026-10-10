# A class or module that is not a value type optparse knows raises
# ArgumentError when the switch is declared, and the switch is not added.
# Object and NilClass are known types: the value passes as it is.
require "optparse"

class Color
end

parser = OptionParser.new("Usage: t")
[Color, Hash, Comparable].each do |type|
  begin
    parser.on("--x=X", type) { |v| p [:x, v] }
  rescue ArgumentError => e
    p [e.class, e.message]
  end
end
begin
  parser.on_tail("--y=Y", "Tail", Color) { |v| p [:y, v] }
rescue ArgumentError => e
  p [e.class, e.message]
end

parser.on("--o=O", Object) { |v| p [:o, v] }
parser.on("--n=N", NilClass) { |v| p [:n, v] }
p parser.parse(["--o=1", "--n", "two", "rest"])
begin
  parser.parse(["--x"])
rescue OptionParser::ParseError => e
  p [e.class, e.message]
end
