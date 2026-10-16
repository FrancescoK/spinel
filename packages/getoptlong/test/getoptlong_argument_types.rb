# The three argument types (required, optional, none) under their long names,
# aliases and unambiguous abbreviations, with the argument joined by `=`,
# attached to a short option or given as the next word, and short options
# bundled behind one dash. Cases taken from ruby/getoptlong's test suite.
require "getoptlong"

def run(argv)
  ARGV.replace(argv)
  opts = GetoptLong.new(
    ["--xxx", "-x", "--aaa", "-a", GetoptLong::REQUIRED_ARGUMENT],
    ["--yyy", "-y", "--bbb", "-b", GetoptLong::OPTIONAL_ARGUMENT],
    ["--zzz", "-z", "--ccc", "-c", GetoptLong::NO_ARGUMENT]
  )
  opts.quiet = true
  seen = []
  opts.each { |opt, arg| seen << "#{opt}: #{arg}" }
  p [seen, ARGV]
end

run(%w[foo bar])
%w[--xxx --xx --x -x --aaa --aa --a -a].each { |o| run(["foo", o, "arg", "bar"]) }
%w[--yyy --y -y --bbb --bb --b -b].each { |o| run(["foo", "bar", o, "arg"]) }
%w[--yyy --y -y --bbb --bb --b -b].each { |o| run(["foo", "bar", o]) }
%w[--zzz --zz --z -z --ccc --cc --c -c].each { |o| run(["foo", o, "bar"]) }

run(%w[--xxx=a=b --yyy=v --yyy= rest])
run(%w[-xVAL -yOPT -y -z])
run(%w[-zcxARG left])
run(%w[-zy right])
run(%w[--yyy --zzz])
run(["--xxx", "-z"])
run(["--xxx", "two\nlines"])
run(%w[- --zzz])
