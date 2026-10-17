# A short switch drops a value it may go without when its pattern refuses
# it, as CRuby does: " [V]" leaves a refused next word in argv and passes
# nil, "[=V]" passes nil and reads a refused attached value as switches.
# With "=", a long switch or a required value, the word is invalid, and a
# long " [V]" leaves the word in argv.
require "optparse"

def run(words)
  parser = OptionParser.new("Usage: t")
  parser.on("-p [V]", "--placed [V]", Integer) { |v| p [:placed, v] }
  parser.on("-q[=V]", Integer) { |v| p [:optional, v] }
  parser.on("-r=V", Integer) { |v| p [:required, v] }
  parser.on("-y [YYY]", { baz: 2, bat: 3 }) { |v| p [:enum, v] }
  parser.on("-a") { p :a }
  argv = words.dup
  parser.parse!(argv)
  p argv
rescue OptionParser::ParseError => e
  p [e.class, e.message, argv]
end

run(%w[-p x])
run(%w[-p 5 x])
run(%w[-px])
run(%w[-p=x])
run(%w[--placed x])
run(%w[-qa])
run(%w[-q7])
run(%w[-q=a])
run(%w[-rx])
run(%w[-y bam])
run(%w[-y baz])
run(%w[-y ba])
