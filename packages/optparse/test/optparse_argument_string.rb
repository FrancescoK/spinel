# An argument given on its own after the names ("=VALUE" or "=[VALUE]")
# declares the switch's value as CRuby does; any other string stays a
# description line. Without its optional value, such a switch passes true,
# as CRuby's Object converter reads nil; one whose names carry the argument
# passes nil, and a placed one ("--name [VALUE]") never converts the nil.
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

parser = OptionParser.new("Usage: t")
parser.on("-x", "--xxx", "=XXX", "Required") { |v| p [:x, v] }
parser.on("-o", "--opt", "=[OPT]", "Optional") { |v| p [:o, v] }
parser.on("--last=A", "=B") { |v| p [:last, v] }
parser.on("-y", "=Y") { |v| p [:y, v] }
parser.on("--int", "Count", "=N", Integer) { |v| p [:int, v] }
parser.on("--desc", " XXX", "[XXX]") { |v| p [:desc, v] }
parser.on("--named[=V]") { |v| p [:named, v] }
parser.on("--named-object[=V]", Object) { |v| p [:named_object, v] }
parser.on("--nil", "=[V]", NilClass) { |v| p [:nil, v] }
parser.on("--placed [V]", TrueClass) { |v| p [:placed, v] }
puts parser.help

[["--xxx"], ["--xxx", "V"], ["--xxx=V"], ["-x", "V"], ["-xV"],
 ["--opt"], ["--opt", "V"], ["--opt=V"], ["-o"], ["-oV"],
 ["--last", "V"], ["-y", "V"], ["--int", "3"], ["--int", "x"],
 ["--desc", "V"], ["--desc=V"],
 ["--named"], ["--named-object"], ["--named-object=V"], ["--nil"], ["--placed"], ["--placed", "-x", "V"]].each { |w| run(parser, w) }
