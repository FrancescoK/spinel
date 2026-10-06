# CRuby reopens its own Mutex here and adds `hi` to it. Spinel builds
# Mutex in C and cannot add methods to it, so it refuses the program.
class Mutex
  def hi = "mine"
end

m = Mutex.new
m.synchronize { puts m.hi }
