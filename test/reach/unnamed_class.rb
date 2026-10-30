# A class nothing names keeps none of its methods, though their names are
# called on other classes; a class named only by a call of one of its
# singleton methods keeps that method and not its instance side (#10592).
# absent: sp_Unused_area sp_Unused_initialize sp_Unused_s_build sp_Util_area sp_Util_initialize
# present: sp_Used_area sp_Used_initialize sp_Util_s_helper
class Unused
  def initialize(w) = @w = w
  def area = @w * 2
  def self.build = new(3)
end
class Util
  def initialize(w) = @w = w
  def area = @w * 5
  def self.helper(x) = x + 1
end
class Used
  def initialize(w) = @w = w
  def area = @w * 3
end
p Used.new(2).area
p Util.helper(4)
