# A value in brackets is optional: "--color[=WHEN]", "--color=[WHEN]" and
# "-c[WHEN]" take only an attached value, and pass nil without one. The next
# word is never the value (#7936).
require "optparse"

parser = OptionParser.new("Usage: tool [OPTIONS]")
parser.on("-v", "--verbose", "Verbose output") { |v| p [:verbose, v] }
parser.on("-c", "--color[=WHEN]", "Colorize output") { |v| p [:color, v] }
parser.on("-x[LEVEL]", "--trace=[LEVEL]") { |v| p [:trace, v] }
parser.on("--list[=A,B]", Array) { |v| p [:list, v] }
puts parser

p parser.parse(["--color", "--color=always", "--color=", "--color", "word"])
p parser.parse(["-c", "-calways", "-c", "word", "-vc", "-cv"])
p parser.parse(["--trace", "--trace=2", "-x", "-x3", "-x=4"])
p parser.parse(["--list", "--list=a,b"])
p parser.parse(["--color", "-v", "--color", "--", "-v"])

# The block can be left out.
quiet = OptionParser.new
quiet.on("--color[=WHEN]")
p quiet.parse(["--color", "word", "--color=never"])
