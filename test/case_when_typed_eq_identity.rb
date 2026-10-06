# `when pa` against a subject of pa's class asks `pa === subj`, which is
# Kernel#=== (rb_equal) for a class that defines only ==: the same object
# matches without calling ==, an equal one through it. Here == takes an
# operand typed as its own class.

def show(log, v)
  p [v, log.size]
  log.clear
end

class P
  attr_accessor :v
  def initialize(v, log)
    @v = v
    @log = log
  end
  def ==(o)
    @log << :peq
    o.v == @v
  end
end
plog = []
pa = P.new(1, plog)
pb = P.new(1, plog)
pc = P.new(2, plog)
pc.v = 3
show(plog, pa == pb)
r = case pa
    when pa then :pa
    else :none
    end
show(plog, r)
r = case pb
    when pa then :pa
    else :none
    end
show(plog, r)
r = case pc
    when pa then :pa
    else :none
    end
show(plog, r)
