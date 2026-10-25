# A switch declared with a Set accepts only the names in it, as one with
# an Array does, and refuses any other word.
require "set"
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

parser = OptionParser.new
parser.on("--mode=MODE", Set["fast", "slow", "fastest"]) { |v| p v }
parser.on("-l", "--level=L", Set[:low, :high]) { |v| p v }
["--mode=fast", "--mode=s", "--mode=fastest", "--mode=fas", "--mode=x",
 "--level=low", "--level=h", "-lx"].each { |w| run(parser, [w, "b"]) }
