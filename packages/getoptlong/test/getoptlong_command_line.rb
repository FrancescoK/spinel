# GetoptLong reading the program's own command line (the .args file),
# the way a script uses it.
require "getoptlong"

opts = GetoptLong.new(
  ["--help", "-h", GetoptLong::NO_ARGUMENT],
  ["--repeat", "-r", GetoptLong::REQUIRED_ARGUMENT],
  ["--name", GetoptLong::OPTIONAL_ARGUMENT]
)
repeat = 1
name = nil
opts.each do |opt, arg|
  case opt
  when "--help"
    puts "help"
  when "--repeat"
    repeat = Integer(arg)
  when "--name"
    name = arg.empty? ? "John" : arg
  end
end
p repeat, name, ARGV
repeat.times { |i| puts "Hello #{name} (#{i})" }
