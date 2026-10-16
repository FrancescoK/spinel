# In `class Time`, `class << Time` is the class's own singleton, as
# `class << self` is: self.utc and self.at there are Time's class methods
# (lib/time.rb's shape).
class Time
  class << Time
    def jan_first(year) = self.utc(year, 1, 1).yday
    def epoch_year = self.at(0).utc.year
  end
end

class Integer
  class << Integer
    def root(n) = self.sqrt(n)
  end
end

p Time.jan_first(2026)
p Time.epoch_year
p Integer.root(16)
