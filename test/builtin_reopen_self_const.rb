# A constant read through self in a reopening of a builtin class, in its
# class methods and its body, is the builtin's constant, as `Float::INFINITY`
# reads it; one the program defines there too.
class Float
  p self::INFINITY > 1
  def self.big?(x) = x >= self::MAX
  class << self
    def tiny = self::EPSILON < 1
  end
end
class Integer
  LIMIT = 7
  def self.limit = self::LIMIT
end
p Float.big?(1.0), Float.tiny, Integer.limit
