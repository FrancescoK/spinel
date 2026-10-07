# ThreadGroup: threads added to a group are listed by it while alive, a
# thread added to a second group leaves the first, and a group answers
# add with itself (webrick's GenericServer#start gathers its request
# threads so, and joins them on shutdown)
g = ThreadGroup.new
q = Queue.new
t1 = Thread.new { q.pop }
t2 = Thread.new { q.pop }
p g.add(t1).equal?(g)
g.add(t2)
p g.list.size, g.list.include?(t1), g.list.include?(t2)
h = ThreadGroup.new
h.add(t2)
p g.list.size, h.list.size, g.list.include?(t2)
p ThreadGroup::Default.list.include?(Thread.current)
p ThreadGroup::Default.list.include?(t1)
q << 1; q << 2
t1.join; t2.join
p g.list.size, h.list.size
p g.enclosed?
