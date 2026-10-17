# The arguments of on set the switch's converter in CRuby's order: a type
# given twice, or before a name that carries an argument, raises
# ArgumentError; a name with an argument after an enum converts the word
# as it is; a type after an enum converts the word.
require "optparse"

def declare(*args)
  parser = OptionParser.new
  parser.on(*args) { |v| p v }
  ["--m=f", "--m=12", "--m"].each do |word|
    parser.parse!([word])
  rescue OptionParser::ParseError => e
    p [e.class, e.message]
  end
rescue ArgumentError => e
  p [:on, e.message]
end

declare(["fast", "slow"], "--m=M")
declare("--m=M", ["fast", "slow"])
declare(["fast"], "--m", "=M")
declare(TrueClass, "--m=M")
declare(Integer, "--m=M")
declare("--m=M", Integer, String)
declare("--m=M", Integer, Integer)
declare(["fast"], "--m=M", Integer)
declare("--m=M", TrueClass)
declare(Integer, "--[no-]m")
declare("--[no-]m", Integer)
declare("--[no-]m[=V]")
declare("--m", "=M", "=[M]")
declare("--m", "=M", "=N")
