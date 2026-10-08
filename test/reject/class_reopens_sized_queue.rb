# CRuby reopens its own SizedQueue here and adds `hi` to it.
# spinel: reject-builtin-class: reopening the builtin class SizedQueue is not supported
class SizedQueue
  def hi = "mine"
end

q = SizedQueue.new(2)
q << 1
puts q.pop
puts q.hi
