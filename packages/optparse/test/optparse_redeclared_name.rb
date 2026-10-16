# A name declared again belongs to the later switch, whole or cut, short
# or long, and the help no longer lists a switch left with no name; a
# switch keeps the names nobody took. An on_tail --help replaces the
# built-in one.
require "optparse"

parser = OptionParser.new("Usage: t")
parser.on("--foo", "first") { p [:foo, 1] }
parser.on("--foo", "second") { p [:foo, 2] }
parser.on("-f", "--fast") { p :fast }
parser.on("-f") { p :f }
parser.on_tail("--help") { p :own_help }
parser.parse!(%w[--foo --fo -f --fast --help])
puts parser
p parser.top.long.keys
