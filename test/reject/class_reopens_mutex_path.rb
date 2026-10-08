# Thread::Mutex is the same class as Mutex.
# spinel: reject-builtin-class: reopening the builtin class Mutex is not supported
class Thread::Mutex
  def hi = "mine"
end

puts Mutex.new.hi
