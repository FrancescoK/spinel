# The default of a writer's optional parameter reads an ivar. The
# writer arm evaluates it with the arm's object as self. Meter's
# attr_accessor puts the call on the writer arms.
class Gauge
  def initialize(notify)
    @notify = notify
  end

  def value=(v, notify = @notify)
    puts "gauge #{v} notify=#{notify}"
  end
end

class Dial
  def initialize
    @step = 5
  end

  def value=(v, step = @step * 2)
    puts "dial #{v} step=#{step}"
  end
end

class Meter
  attr_accessor :value
end

widgets = [Gauge.new(:loud), Dial.new, Meter.new, Gauge.new(:quiet), "text"]
widgets.each do |w|
  w.value = 7 if w.respond_to?(:value=)
end
p widgets[2].value
