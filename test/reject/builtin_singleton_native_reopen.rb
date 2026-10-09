# Direct singleton definitions obey the same limits as a native class body.
# spinel: reject-builtin-class: reopening the builtin class Queue is not supported
def Queue.reachable_helper = :called
q = Queue.new
q << 1
p q.pop
p Queue.reachable_helper
