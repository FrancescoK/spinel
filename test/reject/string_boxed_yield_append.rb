# A block a reopening's proc form yields a boxed String to appends to a copy
# in the default build, so the append would not reach the caller's String.
class String
  def po(a) = yield(a)
end
u = +"m"
(+"ab").po(u) { |v| v << "!" }
p u
