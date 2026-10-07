# --[no-] registers positive and negative long forms while preserving help (#7920).
require "optparse"

parser = OptionParser.new("Usage: demo")
parser.on("-v", "--[no-]verbose", "Verbose output") { |value| p value }
parser.on("-q", "--quiet") { |value| p value }
parser.on_tail("--[no-]color", "Color output") { |value| p value }
puts parser.help

argv = ["first", "--verbose", "--no-verbose", "-vq", "--color", "--no-color", "last"]
begin
  p parser.parse!(argv)
rescue OptionParser::ParseError => e
  p e.class
end

# Each long alias gets its own negative form; short aliases remain positive.
aliases = OptionParser.new("Aliases")
aliases.on("-c", "--[no-]cache", "--[no-]cached") { |value| p value }
alias_args = ["--cache", "--no-cache", "--cached", "--no-cached", "-c"]
begin
  p aliases.parse(alias_args)
rescue OptionParser::ParseError => e
  p e.class
end
p alias_args

# With a required value, only the positive long form consumes a value.
values = OptionParser.new("Values")
values.on("--[no-]name=NAME") { |value| p value }
begin
  p values.parse!(["--name=alice", "--no-name", "keep", "--name", "bob"])
rescue OptionParser::ParseError => e
  p e.class
end

# Both forms work without a callback and stop at the terminator.
no_block = OptionParser.new("No block")
no_block.on("--[no-]feature")
begin
  p no_block.parse!(["--feature", "--no-feature", "--", "--no-feature"])
rescue OptionParser::ParseError => e
  p e.class
end

# Neither boolean form accepts an attached value; argv keeps the remainder.
["--verbose=yes", "--no-verbose=yes"].each do |word|
  words = [word, "keep"]
  begin
    parser.parse!(words)
  rescue OptionParser::ParseError => e
    p e.class
    puts e.message
    p words
  end
end
begin
  values.parse!(["--no-name=alice"])
rescue OptionParser::ParseError => e
  p e.class
  puts e.message
end

# The declaration syntax itself is not an accepted argument.
begin
  parser.parse!(["--[no-]verbose"])
rescue OptionParser::ParseError => e
  p e.class
end
