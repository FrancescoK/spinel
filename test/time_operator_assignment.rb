# `t += n` and `t -= n` on a Time local (the logger gem's Period, `t += SiD
# if hour > 12`): Time + Integer and Time - Integer exist; the operator
# assignment form refused them. Float offsets and a Time held in an ivar
# take the same path.
t = Time.at(0).utc
t += 86400
p t.day
t -= 3600
p [t.day, t.hour]
t += 0.5
p t.usec
class Clock
  def initialize = @t = Time.at(0).utc
  def tick(n)
    @t += n
    self
  end
  def hour = @t.hour
end
p Clock.new.tick(3600).tick(7200).hour
