# A boxed Proc in a slot a user #call shares still takes a positional Hash
# as a positional, not as keywords.

class Cal
  def call(a, h = nil) = [:cal, a, h]
end
pr = proc { |a, k: 1| [a, k] }
h = {k: 3}
[pr, Cal.new].each do |x|
  p x.call(5, {k: 2})
  p x.call(5, h)
end
