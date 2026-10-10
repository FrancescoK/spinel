# An unknown or ambiguous long switch is named in the error by the whole
# word, attached value included ("--x=1"), as CRuby does.
require "optparse"

parser = OptionParser.new("Usage: t")
parser.on("-q", "--quiet") {}
parser.on("--verbose") {}
parser.on("--version") {}

[
  ["--x=1", "b"],
  ["--x="],
  ["--x=a=b"],
  ["--no-x=1"],
  ["--ver=1", "b"],
  ["--x"],
  ["--ver"],
  ["--x", "1"],
  ["--quiet=1"]
].each do |words|
  argv = words.dup
  begin
    parser.parse!(argv)
  rescue OptionParser::ParseError => e
    p [e.class, e.message, argv]
  end
end
