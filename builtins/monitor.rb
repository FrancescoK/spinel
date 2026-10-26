require "builtins/monitor_mixin"

class Monitor
  def new_cond
    MonitorMixin::ConditionVariable.new(__monitor_check("new_cond"))
  end
end
