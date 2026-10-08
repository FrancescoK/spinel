# A String switch refuses an empty value with InvalidArgument, and an Array
# switch passes nil for an empty item between commas. A switch declared
# without a type still passes an empty value as it is (#8050).
require "optparse"

parser = OptionParser.new("Usage: tool [OPTIONS]")
parser.on("-n", "--name=NAME", String) { |v| p [:name, v] }
parser.on("-t", "--tag[=TAG]", String) { |v| p [:tag, v] }
parser.on("-l", "--list=A,B", Array) { |v| p [:list, v] }
parser.on("--note=TEXT") { |v| p [:note, v] }

p parser.parse(["--name=x", "--name", " ", "-ny", "--tag", "--tag=z"])
p parser.parse(["--list=a,,b", "--list", ",x,", "-la,", "--list=,", "--list="])
p parser.parse(["--note=", "--note", ""])

[
  ["--name="],
  ["--name", "", "b"],
  ["-n", "", "b"],
  ["--tag=", "b"],
  ["a", "--name=", "--name=x"]
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
quiet.on("--name=NAME", String)
begin
  quiet.parse(["--name="])
rescue OptionParser::InvalidArgument => e
  p e.message
end
