# Monitor is a Mutex underneath here, so a subclass's synchronize would answer
# nil (CRuby prints 1); refused like the other runtime-built classes.
require "monitor"
module A
  class Monitor < Monitor
  end
end
p A::Monitor.new.synchronize { 1 }
