# A relational operator on a receiver with no static type (here a call on
# nil, which raises) compares at run time, as the arithmetic operators do,
# instead of refusing the program.

class Playback
  def initialize(sink)
    @sink = sink
    @ahead = 0.15
  end

  def full?
    @sink.queued_seconds >= @ahead
  end
end

begin
  Playback.new(nil).full?
rescue NoMethodError => e
  puts e.message
end

x = nil
[-> { x.foo < 1 }, -> { x.foo <= 1.0 }, -> { x.foo > 2 }, -> { x.foo >= 0.5 }].each do |f|
  p f.call
rescue NoMethodError => e
  puts e.message
end
