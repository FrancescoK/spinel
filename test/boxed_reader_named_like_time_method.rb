# a reader of the program's own named like a Time method answers for itself
# on a boxed receiver
class Track
  attr_reader :zone
  def initialize(zone) = @zone = zone
end
class Head
  attr_reader :zone
  def initialize = @zone = 0
end
tracks = [nil, Track.new(*[3])]
tracks.each { |track| p track.zone if track }
p Head.new.zone

class Clock
  attr_reader :usec
  def initialize(u) = @usec = u
end
[Clock.new("u")].each { |c| p c.usec }

class Tz
  attr_accessor :zone
  def initialize(z) = @zone = z
end
[Tz.new(4)].each { |t| p t.zone }

Zoned = Struct.new(:zone)
[Zoned.new(5)].each { |t| p t.zone }

[Time.at(0).utc, Track.new(6)].each { |t| p t.zone }
