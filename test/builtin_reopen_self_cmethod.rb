# In a class method a reopening of a builtin class defines, a call of one of
# the builtin's own class methods on self, or bare, is that class method.

class Time
  def self.year_now = self.now.year > 2000
  def self.u = self.utc(2000, 1, 2).day
  def self.l = Time.local(2001, 2, 3).month
  class << self
    def stamp = self.at(0).utc.year
  end
end
class Integer
  def self.root(n) = self.sqrt(n)
  def self.bare_root(n) = sqrt(n)
end
class String
  def self.mk = self.new("ab")
  def self.twice(s) = s * 2
  def self.use = self.twice("x")
end
p Time.year_now, Time.u, Time.l, Time.stamp, Integer.root(17), Integer.bare_root(26)
p String.mk, String.use
