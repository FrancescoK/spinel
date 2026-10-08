# String block methods bind yielded values and keep fresh or self returns.
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
r = s.block_yield_tail_fresh { |x| p x }
p r, s, r.equal?(s)

s = +"ab"
r = s.block_yield_tail_self { |x| p x }
p r, s, r.equal?(s)

s = +"ab"
r = s.block_yield_return_fresh { |x| p x }
p r, s, r.equal?(s)

s = +"ab"
r = s.block_yield_return_self { |x| p x }
p r, s, r.equal?(s)

s = +"ab"
r = s.block_proc_tail_fresh { |x| p x }
p r, s, r.equal?(s)

s = +"ab"
r = s.block_proc_tail_self { |x| p x }
p r, s, r.equal?(s)

s = +"ab"
r = s.block_proc_return_fresh { |x| p x }
p r, s, r.equal?(s)

s = +"ab"
r = s.block_proc_return_self { |x| p x }
p r, s, r.equal?(s)

# Fresh yielded values can be mutated even when String self uses bytes.
class String
  def block_yield_fresh
    yield +"yielded"
    self
  end
  def block_proc_fresh(&b)
    b.call(+"yielded")
    self
  end
  def block_optional
    yield self if block_given?
    +"optional"
  end
  def block_pair
    yield self, 7
    +"pair"
  end
end

p s.block_yield_fresh { |x| x << "!"; p x }
p s.block_proc_fresh { |x| x << "!"; p x }
p s.block_optional
p s.block_optional { |x| p x }
p s.block_pair { |x, n| p x, n }
p (+"temporary").block_yield_tail_fresh { |x| GC.start; p x }
p (+"temporary").block_proc_return_self { |x| GC.start; p x }

# Method blocks use the same yield binding, including String operations.
def block_read_string(x)
  p x.bytes
end
p s.block_yield_tail_self(&method(:block_read_string))
p s.block_proc_tail_fresh(&method(:block_read_string))

class String
  def block_keyword
    yield text: self
    self
  end
end
p s.block_keyword { |text:| p text }
p s.block_pair { |x, n = 1| p x, n }
