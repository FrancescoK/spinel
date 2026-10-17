# require_exact = true takes only a whole long name, case included, and
# a short letter only as a short switch, as in CRuby; turned off again,
# names complete.
require "optparse"

def run(parser, words)
  argv = words.dup
  parser.parse!(argv)
  p argv
rescue OptionParser::ParseError => e
  p [e.class, e.message, argv]
end

parser = OptionParser.new("Usage: t")
parser.on("-n", "--dry-run") { p :dry_run }
parser.on("--[no-]color") { |v| p [:color, v] }
p parser.require_exact
parser.require_exact = true
run(parser, %w[--dry-run -n --no-color])
run(parser, %w[--dry-ru])
run(parser, %w[--Dry-run])
run(parser, %w[--no-col])
run(parser, %w[-d])
run(parser, %w[--he])
parser.require_exact = false
run(parser, %w[--dry-ru -c])
