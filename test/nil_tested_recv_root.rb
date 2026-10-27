# spinel: gc-stress
# A call on a receiver that may be nil holds the receiver in a temp ahead of
# the nil test. A program method roots its parameters but not its self, so a
# fresh receiver (a reader building a new object) was left unrooted when no
# argument allocated, and the method's own allocations freed it under the
# body still reading it.
class N
  def initialize(v)
    @v = v
  end

  def parent
    @v > 100 ? nil : N.new(@v + 1)
  end

  def churn(data)
    GC.start
    a = []
    100.times { |i| a << N.new(i * 1000) }
    data.is_a?(String) ? @v + data.length : @v
  end

  def via_stmt(arg)
    raise "no parent" if parent.nil?
    parent.churn(arg)
  end

  def via_value(arg)
    x = parent.churn(arg)
    x + 0
  end
end

n = N.new(1)
p n.via_stmt("ab"), n.via_stmt(n)
p n.via_value("abc"), n.via_value(:k)
