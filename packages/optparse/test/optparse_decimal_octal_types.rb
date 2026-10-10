# DecimalInteger reads only decimal digits, so 010 is 10. OctalInteger reads
# octal digits, so 10 is 8. DecimalNumeric reads an Integer, or a Float when
# a "." or an exponent follows the digits. Any other word raises
# InvalidArgument.
require "optparse"

parser = OptionParser.new("Usage: tool [OPTIONS]")
parser.on("-d", "--dec=N", OptionParser::DecimalInteger) { |v| p [:dec, v] }
parser.on("-o", "--oct[=N]", OptionParser::OctalInteger) { |v| p [:oct, v] }
parser.on("--num N", OptionParser::DecimalNumeric, "A number") { |v| p [:num, v] }
puts parser

p parser.parse(["--dec=10", "--dec", "010", "-d-3", "-d", "+4", "--dec=1_000"])
p parser.parse(["--oct=10", "--oct=010", "-o-7", "--oct=7_7", "--oct"])
p parser.parse(["--num", "10", "--num", "-3", "--num", "1_0", "--num", "1.5",
                "--num", "-1.5", "--num", "1e3", "--num", "1E-2"])

[
  ["--dec=0x1", "b"],
  ["--dec=0b1"],
  ["--dec=1.5"],
  ["--dec=x"],
  ["--dec="],
  ["-d", "x", "b"],
  ["--oct=8", "b"],
  ["--oct=0x1f"],
  ["--oct=0b11"],
  ["--oct=1.5"],
  ["--oct="],
  ["--num", "0x1"],
  ["--num", "x", "b"],
  ["--num", ""]
].each do |words|
  argv = words.dup
  begin
    parser.parse!(argv)
  rescue OptionParser::ParseError => e
    p [e.class, e.message, argv]
  end
end
