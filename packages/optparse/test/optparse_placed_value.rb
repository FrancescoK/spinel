# A value in brackets after a space is optional and placed: "--color [WHEN]"
# and "-c [WHEN]" take an attached value or else the next word, unless that
# word looks like a switch. Without one, the block gets nil (#7936).
require "optparse"

parser = OptionParser.new("Usage: tool [OPTIONS]")
parser.on("-v", "--verbose", "Verbose output") { |v| p [:verbose, v] }
parser.on("-c", "--color [WHEN]", "Colorize output") { |v| p [:color, v] }
puts parser

p parser.parse(["--color", "--color=always", "--color", "never", "word"])
p parser.parse(["-calways", "-c", "auto", "-vc", "-cv"])
p parser.parse(["--color", "-v", "--color", "-", "--color"])
p parser.parse(["-c", "--", "-v"])

begin
  parser.parse(["--color", "-z", "word"])
rescue OptionParser::ParseError => e
  p e.class
  p e.message
end
