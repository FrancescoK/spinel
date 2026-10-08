# Reading shared self does not make a fresh block-method return the receiver.
# A boxed receiver reaches the proc form, including its explicit returns.
class String
  def block_fresh_tail
    yield self
    +"fresh"
  end
  def block_fresh_return
    yield self
    return +"explicit"
  end
  def block_self_tail
    yield self
    self
  end
  def block_self_return
    yield self
    return self
  end
  def block_mixed_return(fresh)
    yield self
    return +"early" if fresh
    self
  end
end

s = +"ab"
s << "!"
values = [s, 1]
p values.first.block_fresh_tail { |x| p x }
p values.first.block_fresh_return { |x| p x }
p values.first.block_self_tail { |x| p x }
p values.first.block_self_return { |x| p x }
p values.first.block_mixed_return(true) { |x| p x }
p values.first.block_mixed_return(false) { |x| p x }
p s
