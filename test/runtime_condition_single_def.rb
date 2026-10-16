# A def under a condition only the run time decides, with no other def of
# the name, defines the method only when its branch runs: called otherwise it
# raises NoMethodError, as in CRuby.
class Shape
  if ENV["SPINEL_TEST_UNSET_VARIABLE"]
    def area(scale) = scale * 2
  end
  unless ENV["SPINEL_TEST_UNSET_VARIABLE"]
    def perimeter = 4
  end
  def self.flag = ENV["SPINEL_TEST_UNSET_VARIABLE"]
  if flag
    def self.build = new
  end
end

begin
  Shape.new.area(3)
rescue NoMethodError => e
  puts e.message
end
p Shape.new.perimeter
begin
  Shape.build
rescue NoMethodError => e
  puts e.message
end
