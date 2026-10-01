# SPINEL_SCHED_STATS=1 reports when the program ends with `exit` or an
# uncaught exception, not only when main returns -- and once when main
# returns, where the drain and the exit hook both run. The test runs itself
# as a child and counts the reports on the child's stderr. CRuby has no such
# report, so there the answer is 1 without looking.
require "open3"

def reports(how)
  return 1 unless RUBY_ENGINE == "spinel"
  ENV["SPINEL_SCHED_STATS"] = "1"
  _out, err, _status = Open3.capture3($0, how)
  ENV.delete("SPINEL_SCHED_STATS")   # this process reports at its exit too
  err.scan("[sched] monitor:").size
end

if ARGV[0]
  t = Thread.new { 1 + 1 }
  t.join
  exit 0 if ARGV[0] == "exit"
  raise "boom" if ARGV[0] == "raise"
  # "return": main ends normally
else
  p reports("exit")
  p reports("raise")
  p reports("return")
end
