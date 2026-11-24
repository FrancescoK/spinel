# The ivars a computed instance_variable_set adds to an object are listed by
# pp sorted by name among the declared ones, as CRuby's pp lists
# instance_variables.sort; p keeps the declared ones first.
require "tmpdir"
class S; def initialize; @z = 1; @b = 2; end; end
class S1; def initialize = @m = 1; end
s = S.new
s.instance_variable_set(ARGV.empty? ? :@a : :@q, 3)
s.instance_variable_set(ARGV.empty? ? :@y : :@r, [s.class])
s1 = S1.new
s1.instance_variable_set(ARGV.empty? ? :@a : :@q, nil)
s1.instance_variable_set(ARGV.empty? ? :@n : :@q, S1.new)
path = File.join(Dir.tmpdir, "pp_lists_computed_ivars_by_name_#{Process.pid}.txt")
saved = $stdout.dup
$stdout.reopen(path, "w")
pp s
p s
pp s1, S1.new
pp [s1]
$stdout.flush
$stdout.reopen(saved)
puts File.read(path).gsub(/0x\h+/, "0x")
File.delete(path)
