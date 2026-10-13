# Thread#raise on another thread answers nil, as the boxed receiver's arm
# already did; the typed one answered the thread itself.
done = Thread.new {}
done.join
p done.raise("ignored")

q = Queue.new
waiting = Thread.new do
  q.pop
  :finished
rescue => e
  e.message
end
sleep 0.05
p waiting.raise("stop")
p waiting.value
