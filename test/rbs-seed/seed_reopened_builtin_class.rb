# spinel: rbs-seed-run
# A seed naming a builtin class the program reopens (activesupport reopens
# Time, then declares `TimeWithZone#time: () -> Time`). The reopen makes Time
# a class of the program, and the seed pinned the slot to an object of that
# class -- a pointer -- where every Time is Spinel's by-value Time, so the
# C did not compile. It names the builtin's own kind, as `self` in the
# reopen has; a nilable one, which that kind has no nil for, is boxed.
class Time
  def shout = "#{year}!"
end

class SeedTimeBox
  def initialize(t)
    @t = t
    @maybe = nil
  end

  def time = @t
  def maybe = @maybe
  def set(t) = @maybe = t
end

b = SeedTimeBox.new(Time.at(0).utc)
p b.time.year, b.time.shout, b.maybe
b.set(Time.at(60).utc)
p b.maybe.min
