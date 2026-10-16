# The errors get raises while reading: an unknown or ambiguous option, a
# missing argument and a needless one, each under GetoptLong::Error, and the
# state the object keeps afterwards (error, error_message, get answering nil).
require "getoptlong"

def opts_for(argv)
  ARGV.replace(argv)
  opts = GetoptLong.new(
    ["--verbose", "-v", GetoptLong::NO_ARGUMENT],
    ["--version", GetoptLong::NO_ARGUMENT],
    ["--name", "-n", GetoptLong::REQUIRED_ARGUMENT]
  )
  opts.quiet = true
  opts
end

def run(argv)
  opts = opts_for(argv)
  seen = []
  begin
    opts.each { |opt, arg| seen << [opt, arg] }
    p [:ok, seen, ARGV]
  rescue GetoptLong::Error => e
    p [e.class, e.class.superclass, e.message, seen, ARGV]
    p [opts.error, opts.error?, opts.error_message, opts.get, opts.terminated?]
    begin
      opts.terminate
    rescue RuntimeError => e2
      p e2.message
    end
  end
end

run(%w[--verbose --bogus x])
run(%w[-q])
run(%w[-vq])
run(%w[--ver])
run(%w[--vers])
run(%w[--name])
run(%w[-n])
run(%w[-v --name])
run(%w[--verbose=yes])
run(%w[--version=1.0])

p GetoptLong::AmbiguousOption.ancestors.take(3)
p [GetoptLong::NeedlessArgument, GetoptLong::MissingArgument, GetoptLong::InvalidOption].map(&:superclass)
o = opts_for([])
p o.quiet, o.quiet?
o.quiet = false
p o.quiet?
