# A Numeric switch reads an Integer, a Float or a fraction as a Rational,
# as CRuby does.
require "optparse"

parser = OptionParser.new("Usage: t")
parser.on("--n=N", Numeric) { |v| p [v, v.class] }

["3", "-3", "+3", "010", "0x1f", "0b1", "1_000", "1.5", "5.", "1e3", "1E-2",
 "1/3", "-1/3", "1.5/2", "1/2.5", "3/1", "x", "1/", "/3", "1_", ""].each do |word|
  argv = ["--n=" + word, "b"]
  begin
    parser.parse!(argv)
    p argv
  rescue OptionParser::ParseError => e
    p [e.class, e.message, argv]
  end
end
parser.parse!(["--n", "7"])
