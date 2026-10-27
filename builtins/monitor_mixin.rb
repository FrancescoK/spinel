# MonitorMixin, spliced by the parser when a program names `MonitorMixin`
# and defines none of its own: an includer's synchronize is the reentrant
# lock of a Monitor it holds, and new_cond gives a condition variable bound
# to that monitor. activesupport's Concurrency::ShareLock includes it and
# waits on one in nested synchronize blocks.
#
# The monitor is made on first use, so an includer whose initialize does
# not call super has one too (CRuby's MonitorMixin#initialize makes it
# there). A wait releases the monitor however deeply its owner holds it, and
# takes it back at the same depth, as CRuby's Monitor#wait_for_cond does.
module MonitorMixin
  class ConditionVariable
    def initialize(monitor)
      @monitor = monitor
      @cond = ::ConditionVariable.new
    end

    def wait(timeout = nil)
      check_owner
      if timeout
        !@cond.wait(@monitor, timeout).nil?
      else
        @cond.wait(@monitor)
        true
      end
    end

    def wait_while
      wait while yield
    end

    def wait_until
      wait until yield
    end

    def signal
      check_owner
      @cond.signal
    end

    def broadcast
      check_owner
      @cond.broadcast
    end

    private

    def check_owner
      raise ThreadError, "current fiber not owner" unless @monitor.owned?
    end
  end

  def mon_initialize
    @mon_data = ::Monitor.new
    nil
  end

  def synchronize
    __mon_data.synchronize { yield }
  end

  def mon_synchronize
    __mon_data.synchronize { yield }
  end

  def mon_enter
    __mon_data.lock
    nil
  end

  def mon_exit
    __mon_data.unlock
    nil
  end

  def mon_try_enter
    __mon_data.try_lock
  end

  def try_mon_enter
    __mon_data.try_lock
  end

  def mon_locked?
    __mon_data.locked?
  end

  def mon_owned?
    __mon_data.owned?
  end

  def new_cond
    MonitorMixin::ConditionVariable.new(__mon_data)
  end

  private

  def __mon_data
    @mon_data ||= ::Monitor.new
  end
end
