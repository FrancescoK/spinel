# Spinel has no Date or DateTime of its own: a program that defines one
# (a pure-Ruby Date, with its initialize and class methods) owns the class,
# and its methods stay its own -- `self.class` in them is that class, and a
# subclass inherits them. A bare reopening that only adds instance methods
# keeps being treated as a builtin's.
class Date
  class << self
    def civil(y, m, d) = new(y, m, d)

    private

    def civil_to_jd(y, m, d) = (1461 * (y + 4800 + (m - 14) / 12)) / 4 + (367 * (m - 2 - 12 * ((m - 14) / 12))) / 12 - (3 * ((y + 4900 + (m - 14) / 12) / 100)) / 4 + d - 32075
  end

  def initialize(y, m, d)
    @year = y
    @mon = m
    @mday = d
  end

  attr_reader :year, :mon, :mday

  def jd = self.class.__send__(:civil_to_jd, @year, @mon, @mday)
  def yday = jd - self.class.__send__(:civil_to_jd, @year, 1, 1) + 1
  def to_s = format("%04d-%02d-%02d", @year, @mon, @mday)
end

class DateTime < Date
  def initialize(y, m, d, h = 0)
    super(y, m, d)
    @hour = h
  end

  def to_s = "#{super}T#{format("%02d", @hour)}"
end

class Date
  def weekday = (jd + 1) % 7
end

d = Date.civil(2024, 2, 29)
p d.jd, d.yday, d.to_s, d.weekday, d.class
t = DateTime.new(2024, 3, 1, 5)
p t.jd, t.yday, t.to_s, t.weekday, t.class
