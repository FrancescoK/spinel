# String block methods keep their actual return value and receiver identity.
class String
  def block_yield_tail_fresh
    yield self
    +"fresh"
  end
  def block_yield_tail_self
    yield self
    self
  end
  def block_yield_return_fresh
    yield self
    return +"fresh"
  end
  def block_yield_return_self
    yield self
    return self
  end
  def block_proc_tail_fresh(&b)
    b.call(self)
    +"fresh"
  end
  def block_proc_tail_self(&b)
    b.call(self)
    self
  end
  def block_proc_return_fresh(&b)
    b.call(self)
    return +"fresh"
  end
  def block_proc_return_self(&b)
    b.call(self)
    return self
  end
end

s = +"ab"
r = s.block_yield_tail_fresh { |x| x << "!" }
r << "?"
p r, s, r.equal?(s)

s = +"ab"
r = s.block_yield_tail_self { |x| x << "!" }
r << "?"
p r, s, r.equal?(s)

s = +"ab"
r = s.block_yield_return_fresh { |x| x << "!" }
r << "?"
p r, s, r.equal?(s)

s = +"ab"
r = s.block_yield_return_self { |x| x << "!" }
r << "?"
p r, s, r.equal?(s)

s = +"ab"
r = s.block_proc_tail_fresh { |x| x << "!" }
r << "?"
p r, s, r.equal?(s)

s = +"ab"
r = s.block_proc_tail_self { |x| x << "!" }
r << "?"
p r, s, r.equal?(s)

s = +"ab"
r = s.block_proc_return_fresh { |x| x << "!" }
r << "?"
p r, s, r.equal?(s)

s = +"ab"
r = s.block_proc_return_self { |x| x << "!" }
r << "?"
p r, s, r.equal?(s)

# Fresh receivers survive allocation in the block and in later arguments.
def block_receiver
  +"temporary"
end
p block_receiver.block_yield_tail_self { |x| GC.start; x << "!" }
p block_receiver.block_proc_return_self { |x| GC.start; x << "?" }
