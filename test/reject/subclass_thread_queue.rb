# Thread::Queue names the builtin Queue (#7075).
# spinel: reject-subclass: class Jobs < Queue: subclassing Queue
class Jobs < Thread::Queue
end

q = Jobs.new
q << 1
p q.pop
