# SPINEL_SCHED_STATS=1 reports when the program ends with `exit` (or an
# uncaught exception), not only when main returns. The test runs itself as a
# child and looks for the report on the child's stderr. CRuby has no such
# report, so there the answer is true without looking.
require "open3"

if ARGV[0]
  t = Thread.new { 1 + 1 }
  t.join
  case ARGV[0]
  when "exit" then exit 0
  when "raise" then raise "boom"
  end
  exit 0
end

def reported?(how)
  return true unless RUBY_ENGINE == "spinel"
  ENV["SPINEL_SCHED_STATS"] = "1"
  _out, err, _status = Open3.capture3($0, how)
  ENV.delete("SPINEL_SCHED_STATS")   # this process reports at its exit too
  err.include?("[sched] monitor:")
end

p reported?("exit")
p reported?("raise")
