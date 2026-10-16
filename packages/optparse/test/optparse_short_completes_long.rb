# A letter no short switch has completes a long name, as the rest of a
# long one does: -h is --help, -c turns --[no-]color on, a value comes
# attached or as the next word, and the rest of the word is read as
# switches again. A letter two long names start is ambiguous, one none
# starts invalid; both errors name the word.
require "optparse"

def run(words)
  parser = OptionParser.new("Usage: t")
  parser.on("-n", "--dry-run") { p :dry_run }
  parser.on("--draft") { p :draft }
  parser.on("--size=N", Integer) { |v| p [:size, v] }
  parser.on("--[no-]color") { |v| p [:color, v] }
  parser.on("--verbose") { p :verbose }
  argv = words.dup
  parser.parse!(argv)
  p argv
rescue OptionParser::ParseError => e
  p [e.class, e.message, argv]
end

run(%w[-c])
run(%w[-s5 x])
run(%w[-s 5])
run(%w[-s])
run(%w[-vn])
run(%w[-nv])
run(%w[-d])
run(%w[-dr])
run(%w[-z])
run(%w[-vz])
run(%w[-v=1])
run(%w[-h])
