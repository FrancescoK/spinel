# spinel: rbs-seed-run
# A Time argument reaches a Time parameter of a class method called on a
# Class value: the dynamic call boxes it, and the parameter takes it out of
# the box through the checked unbox, which raises TypeError for a value of
# another class instead of reading its memory as a Time (#9381).
class TimeArgDispatchProbe
  SLOTS = []

  def self.selected
    SLOTS[0]
  end

  def self.take_time(value)
    value
  end

  def self.shift(value, by)
    value + by
  end
end

TimeArgDispatchProbe::SLOTS[0] = TimeArgDispatchProbe
receiver = TimeArgDispatchProbe.selected
t = receiver.take_time(Time.at(0).utc)
p t.year, t.utc?
p receiver.shift(Time.at(10).utc, 5).to_i
p TimeArgDispatchProbe.take_time(Time.at(60).utc).min
