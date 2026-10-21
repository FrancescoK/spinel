# A builtin class trial must leave the boxed call's user targets recorded.
class Units
  def self.size = 9
  def size = 3
end
class Other
  def size = 4
end
[Units.new, Other.new, Units].each { |value| p value.size }
