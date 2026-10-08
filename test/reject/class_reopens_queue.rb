# CRuby reopens its own Queue here and adds `hi` to it.
# spinel: reject-builtin-class: reopening the builtin class Queue is not supported
class Queue
  def hi = "mine"
end

q = Queue.new
q << 1
puts q.pop
puts q.hi
