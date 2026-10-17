# A Proc, a lambda or a Method given among the arguments of on handles the
# switch, as a block does in CRuby; with a block too it is given twice.
require "optparse"

def handler(value)
  p [:method, value]
end

parser = OptionParser.new("Usage: t")
parser.on("--method", "With a method", method(:handler))
parser.on("--lambda=V", ->(value) { p [:lambda, value] })
parser.on("-p", proc { |value| p [:proc, value] })
parser.parse!(%w[--method --lambda=1 -p])

begin
  parser.on("--twice", method(:handler)) { |value| p value }
rescue ArgumentError => e
  p e.message.start_with?("argument block given twice")
end
puts parser.help
