# M is Mutex, so `class M` reopens Mutex.
M = Mutex

class M
  def hi = "mine"
end

puts Mutex.new.hi
