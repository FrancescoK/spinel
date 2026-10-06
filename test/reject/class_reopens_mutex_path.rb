# Thread::Mutex is the same class as Mutex.
class Thread::Mutex
  def hi = "mine"
end

puts Mutex.new.hi
