# M is Mutex, so `class M` reopens Mutex.
# spinel: reject-builtin-class: reopening the builtin class Mutex is not supported
M = Mutex

class M
  def hi = "mine"
end

puts Mutex.new.hi
