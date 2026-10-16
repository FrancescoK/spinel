# Reading one option at a time with get / get_option, stopping early with
# terminate (the rest goes back to ARGV, permuted words first), and each /
# each_option on an object already terminated.
require "getoptlong"

def opts_for(argv)
  ARGV.replace(argv)
  GetoptLong.new(
    ["--verbose", "-v", GetoptLong::NO_ARGUMENT],
    ["--name", "-n", GetoptLong::REQUIRED_ARGUMENT]
  )
end

opts = opts_for(%w[a -v b --name x c])
p opts.terminated?, opts.get, opts.terminated?
p opts.get_option
p opts.get, opts.terminated?, ARGV, opts.get

opts = opts_for(%w[a -v b --name x c])
p opts.get
p opts.terminate.equal?(opts), opts.terminated?, ARGV
p opts.terminate, opts.get
n = 0
opts.each { n += 1 }
p n

opts = opts_for(%w[-vn first second])
r = []
opts.each_option { |name, arg| r << [name, arg] }
p r, ARGV

opts = opts_for([])
p opts.get, opts.terminated?, ARGV
