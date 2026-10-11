# top.long and top.short hold the switches declared with on; a name added
# to either is accepted as that switch, the way minitest aliases its
# --include as --name.
require "optparse"

options = {}
parser = OptionParser.new("Usage: t [options]") do |opts|
  opts.on "-i", "--include PATTERN", "Include" do |a|
    options[:include] = a
  end
  opts.on "-v", "--verbose", "Verbose" do
    options[:verbose] = true
  end

  def opts.topdict(name)   = (name.length > 1 ? top.long : top.short)
  def opts.alias(from, to) = (dict = topdict(from) ; dict[to] = dict[from])

  opts.alias "include", "name"
  opts.alias "i",       "n"
end

p parser.top.long.keys
p parser.top.short.keys
parser.parse!(["--name", "foo"])
p options
parser.parse!(["-nbar", "-v"])
p options
parser.parse!(["--name=baz"])
p options
begin
  parser.parse!(["-x"])
rescue OptionParser::InvalidOption => e
  p e.message
end
puts parser
