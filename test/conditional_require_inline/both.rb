module Both
  def self.v = 7
  class Box
    attr_reader :x
    def initialize(x) = @x = x
    def twice = @x * 2
  end
end
puts "both loaded"
