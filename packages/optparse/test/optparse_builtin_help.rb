# --help prints the help and exits, as CRuby's built-in switch does. A
# --help the program declares wins, and the built-in one completes after
# the switches from on, beside the on_tail ones.
require "optparse"

def run(parser, words)
  argv = words.dup
  begin
    parser.parse!(argv)
    p argv
  rescue OptionParser::ParseError => e
    p [e.class, e.message, argv]
  end
end

own = OptionParser.new("Usage: own")
own.on("--help", "Mine") { puts "own help" }
run(own, ["--help"])
run(own, ["--he"])

host = OptionParser.new("Usage: host")
host.on("--host=H") { |h| p h }
run(host, ["--h"])

tail = OptionParser.new("Usage: tail")
tail.on_tail("--host=H") { |h| p h }
run(tail, ["--h"])

parser = OptionParser.new("Usage: t")
parser.on("-v", "--verbose", "Be loud") { puts "verbose" }
run(parser, ["--help=1"])
run(parser, ["--", "--help"])
run(parser, ["-v", "--HELP", "x"])
puts "not reached"
