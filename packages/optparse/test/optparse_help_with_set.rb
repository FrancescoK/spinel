# The help lists every name of a switch and its argument when the program
# also uses Set: short and long names, a long name alone, several long
# names, and required and optional arguments.
require "set"
require "optparse"

seen = Set.new
parser = OptionParser.new("Usage: tool [OPTIONS]")
parser.on("-v", "--verbose", "Be loud") { seen << :verbose }
parser.on("--dry-run", "Change nothing") { seen << :dry_run }
parser.on("-c", "--color", "--colour", "Paint the output") { seen << :color }
parser.on("-n", "--name=NAME", "Who to greet") { |v| seen << v }
parser.on("-l", "--level[=N]", Integer, "How much") { |v| seen << v }
parser.on("-q", "Say nothing") { seen << :quiet }
puts parser.help
parser.parse(["-v", "--dry-run", "--colour", "-nAmy", "--level=2", "-q"])
p seen.to_a
