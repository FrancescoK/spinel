# `Kernel.raise` in a method added to Thread is Kernel's raise, which raises
# here, while a bare `raise` there is Thread#raise, which raises in that
# thread (and does nothing to a dead one). The Kernel receiver was dropped
# as for any Kernel function, and the bare call then took self, so
# `Kernel.raise` became Thread#raise on the dead thread and answered nil.
class Thread
  def tag
    self[:tag] || Kernel.raise(KeyError, "no tag")
  end

  def bare_raise
    raise(KeyError, "bare")
  end

  def say(s)
    Kernel.puts(s)
  end
end

t = Thread.new {}
t.join
begin
  t.tag
  p :not_raised
rescue KeyError => e
  p e.message
end
t[:tag] = "x"
p t.tag
t.bare_raise   # Thread#raise on a dead thread: nothing raised here
p :bare_raise_is_the_threads
t.say("hi")
