# An Integer or Float type converts the value before the block gets it.
# Integer reads 0x, 0b and 0 prefixes and underscores, Float reads a bare
# ".5" or an exponent. Any other word raises InvalidArgument, and argv
# keeps the words after that value (#7982).
require "optparse"

parser = OptionParser.new("Usage: tool [OPTIONS]")
parser.on("-n", "--count=N", Integer) { |v| p [:count, v] }
parser.on("-l", "--level[=L]", Integer) { |v| p [:level, v] }
parser.on("-r", "--ratio=R", Float, "Sampling ratio") { |v| p [:ratio, v] }
parser.on("-q", "--quiet") { |v| p [:quiet, v] }
puts parser

p parser.parse(["--count=12", "--count", "-3", "-n0x1f", "-n", "0b11", "-qn010", "--count=1_000"])
p parser.parse(["--ratio=1.5", "--ratio", "2", "-r1e3", "-r", "-.5", "--ratio=1E-2"])
p parser.parse(["--level", "word", "--level=+7", "-l"])
p parser.parse(["--count=12"]).length

[
  ["a", "--count", "x", "b", "c"],
  ["--count=12abc", "b"],
  ["--count=1.5"],
  ["--count="],
  ["--count", "1__0"],
  ["--count=08"],
  ["-n0_9", "b"],
  ["-nx", "b"],
  ["-n", "x", "b"],
  ["-qnx", "b"],
  ["--level=x"],
  ["--ratio", "abc", "b"],
  ["-r1.5x"],
  ["--ratio", "."]
].each do |words|
  argv = words.dup
  begin
    parser.parse!(argv)
  rescue OptionParser::ParseError => e
    p [e.class, e.message, argv]
  end
end

# The block can be left out; the value is still checked.
quiet = OptionParser.new
quiet.on("--count=N", Integer)
p quiet.parse(["--count=3", "word"])
begin
  quiet.parse(["--count=x"])
rescue OptionParser::InvalidArgument => e
  p e.message
end
