# system with an environment Hash ahead of the command: the child gets this
# process's environment with the Hash's names set, and a nil value unset.
p system({"SPX_A" => "one"}, "echo $SPX_A")
p system({"SPX_A" => "one", "SPX_B" => "two"}, "sh", "-c", "echo $SPX_A-$SPX_B")
ENV["SPX_C"] = "parent"
system({"SPX_C" => nil}, "echo [$SPX_C]")
system({"SPX_C" => "child"}, "echo [$SPX_C]")
system("echo [$SPX_C]")
p ENV["SPX_A"]

# the value form, and $? after it
r = system({"SPX_D" => "4"}, "test \"$SPX_D\" = 5")
p r
p $?.exitstatus

# through a splat, and from a method
args = [{"SPX_E" => "e"}, "echo $SPX_E"]
p system(*args)
def run(env, cmd) = system(env, cmd)
p run({"SPX_F" => "f"}, "echo $SPX_F")

# names and values are checked before the child starts
begin
  system({"A=B" => "x"}, "true")
rescue ArgumentError => e
  p e.message
end
begin
  system({"SPX_G" => "g"})
rescue ArgumentError => e
  p e.message
end

# a value that may be either is told apart when the call runs
env = ARGV.empty? ? {"SPX_H" => "h"} : "echo no"
p system(env, "echo [$SPX_H]")

# an empty Hash literal is an environment with nothing to change
p system({}, "echo empty-hash")

# each argument converts with to_str once
class OnceArg
  def initialize; @n = 0; end
  def to_str; @n += 1; "arg#{@n}"; end
end
p system({}, "echo", OnceArg.new)
