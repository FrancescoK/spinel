# A class method the program defines itself wins over the builtin's in a
# parameter default: self.now below is the program's, not Time.now.
class Time
  class << Time
    def now = :mine
    def fresh(t = self.now) = t
  end
end

p Time.fresh
