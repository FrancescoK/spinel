# An empty reopening of Monitor is still a reopening of the builtin class.
# spinel: reject-builtin-class: reopening the builtin class Monitor is not supported
class Monitor
end

Monitor.new.synchronize { puts "ok" }
