# An empty reopening of Monitor is still a reopening of the builtin class.
class Monitor
end

Monitor.new.synchronize { puts "ok" }
