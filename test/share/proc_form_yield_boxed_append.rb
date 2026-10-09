# A block a reopening's proc form yields a boxed String to appends to the
# caller's String when Strings are shared.
class String
  def po(a) = yield(a)
end
u = +"m"
(+"ab").po(u) { |v| v << "!" }
p u
w = +"w"
p (+"ab").po(w) { |v| v << "?"; v }
p w
