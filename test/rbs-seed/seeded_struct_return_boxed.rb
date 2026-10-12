# spinel: rbs-seed-run
# A boxed value through a seeded return of a by-value kind (Time, Range):
# the instance variables here start nil, so they are boxed, and each method
# answers one through a `-> Time` / `-> Range` signature (activesupport's
# TimeWithZone#time is `@time ||= ...` declared `-> Time`). The return was
# emitted without unboxing -- an sp_RbVal through an sp_Time function -- and
# the C did not compile. A method whose value is the write itself
# (`def put(t) = @t = t`) answered a zeroed Time instead.
class Time
  def shout = "#{year}!"
end

class Range
  def mid = (first + last) / 2
end

class SeedStructBox
  def initialize(t, n)
    @u = t
    @n = n
    @t = nil
    @r = nil
  end

  def time = @t ||= @u + 60
  def plain_time = @t
  def rng = @r ||= (0..@n)
  def put(t) = @t = t
end

b = SeedStructBox.new(Time.at(0).utc, 4)
p b.time.min, b.plain_time.shout, b.rng.mid, b.rng.size
p b.put(Time.at(7200).utc).hour
