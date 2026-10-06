# CRuby reopens its own Monitor here and adds `hi` to it. Spinel builds
# Monitor in C and cannot add methods to it, so it refuses the program.
class Monitor
  def hi = "mine"
end

m = Monitor.new
m.synchronize { puts m.hi }
