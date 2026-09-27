# `def m(...) = recv.target(...)` called with a splat forwards the spread
# arguments to the target, and a leading parameter before `...` is kept.
class Status
  def report(code, track = 0)
    puts "#{code},#{track}"
  end

  def kw(code, track = 0, sector: 1)
    puts "#{code},#{track},#{sector}"
  end

  def three(a, b = 7, c = 9)
    puts "#{a},#{b},#{c}"
  end
end

class Drive
  def initialize
    @status = Status.new
  end

  def report(...) = @status.report(...)
  def kw(...) = @status.kw(...)
  def three(...) = @status.three(...)
  def lead(a, ...) = @status.report(a, ...)
end

d = Drive.new
block = [18]
d.report(26, *block)
d.report(*[26, 18])
d.report(26, *[])
d.report(26, 18)
d.kw(26, *block, sector: 3)
d.three(1, *[2, 3])
d.three(*[1])
d.lead(5, *block)
d.lead(5)
begin
  d.report(1, *[2, 3])
rescue ArgumentError => e
  puts e.message
end

module Box
  def self.show(a, b = 5) = puts("#{a}:#{b}")
end

module Relay
  def self.show(...) = Box.show(...)
end

Relay.show(1, *[2])
Relay.show(*[4])

def target(a, b = 0) = puts("#{a},#{b}")
def fwd(...) = target(...)
fwd(1, *[2])
fwd(*[3])
