# In `class Time`, `class << Time` is the class's own singleton, as
# `class << self` is: self.utc, self.now and self.at there are Time's class
# methods, in a body and in a parameter's default, positional or keyword
# (lib/time.rb's shape).
class Time
  class << Time
    def jan_first(year) = self.utc(year, 1, 1).yday
    def recent?(now = self.now) = now.year > 2000
    def epoch_year = self.at(0).utc.year
    def kw_now(now: self.now) = now.year > 2000
  end
end

class Integer
  class << Integer
    def root(n) = self.sqrt(n)
  end
  def self.root_or(n = self.sqrt(81)) = n
end

p Time.jan_first(2026)
p Time.recent?
p Time.epoch_year
p Integer.root(16)
p Integer.root_or
p Integer.root_or(3)
p Time.kw_now
