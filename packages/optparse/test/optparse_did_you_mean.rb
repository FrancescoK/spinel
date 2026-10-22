# An invalid or ambiguous option names the switches it could have meant,
# without the program requiring did_you_mean.
require "optparse"

parser = OptionParser.new
parser.on("--bar")
parser.on("--baz")
parser.on("--cuz")
parser.on("--verbose")

%w[--baa --cuu --verbos --zzzz --ba].each do |word|
  parser.parse([word])
rescue OptionParser::ParseError => e
  puts e.message
end
