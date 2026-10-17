# spinel: rbs-seed-run
# A return declared as an instance type on a method that answers the class
# itself through `||` and `&&` (seed_ret_instance_for_class.rb): the RBS means
# singleton(...), so the declaration is ignored. The walk that decides
# whether every value of the method is a class stopped at `||` and `&&`, kept the
# declaration, and the C return `sp_VlLogicStory *` was handed an sp_Class, which
# the C compiler refused.
class VlLogicStory
  def self.none = "VlLogicStory.none"
end

class VlLogicSearch
  def initialize(what) = @what = what

  def searched_model
    (VlLogicStory || VlLogicStory) && VlLogicStory
  end
end

p VlLogicSearch.new(:stories).searched_model.none
p VlLogicSearch.new(:comments).searched_model.none
