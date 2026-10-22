# Literal and computed send arms retain their resolved user targets.
# spinel: gc-stress
class SendTarget
  def run = 4
  def x = 7
  def self.y = 9
end
class SendTarget
  def x = 8
end
s = SendTarget.new
p s.send(:run)
p s.public_send(:x)
p s.method(:run).call
p SendTarget.method(:y).call
name = [:run, :x][ARGV.size]
p s.send(name)
p s.public_send(name)
