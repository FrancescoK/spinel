# The ArgumentErrors GetoptLong.new and set_options raise for a malformed
# option list, from ruby/getoptlong's test suite, and set_options once
# reading has started.
require "getoptlong"

def check
  yield
  p :no_error
rescue ArgumentError, RuntimeError => e
  p [e.class, e.message]
end

check { GetoptLong.new([]) }
check { GetoptLong.new("foo") }
check { GetoptLong.new([[]]) }
check { GetoptLong.new([1]) }
%w[verbose -verbose -- +].each do |bad|
  check { GetoptLong.new([bad, "-v", GetoptLong::NO_ARGUMENT]) }
end
%w[v - -- +].each do |bad|
  check { GetoptLong.new(["--verbose", bad, GetoptLong::NO_ARGUMENT]) }
end
check { GetoptLong.new(["--verbose", "-v", "foo"]) }
check { GetoptLong.new(["--verbose", GetoptLong::NO_ARGUMENT, GetoptLong::REQUIRED_ARGUMENT]) }
check { GetoptLong.new(["--verbose", GetoptLong::NO_ARGUMENT], ["--verbose", GetoptLong::NO_ARGUMENT]) }
check { GetoptLong.new(["--a", "-a", GetoptLong::NO_ARGUMENT], ["--b", "-a", GetoptLong::NO_ARGUMENT]) }
check { GetoptLong.new }

opts = GetoptLong.new
opts.set_options(["--size", "-s", GetoptLong::REQUIRED_ARGUMENT])
ARGV.replace(%w[-s 3 --size=4 x])
p opts.get, opts.get_option, opts.get, ARGV
check { opts.set_options(["--other", GetoptLong::NO_ARGUMENT]) }
