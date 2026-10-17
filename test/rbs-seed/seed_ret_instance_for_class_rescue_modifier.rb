# spinel: rbs-seed-run
# A return declared as an instance type on a method that answers the class
# itself through a rescue modifier (seed_ret_instance_for_class.rb): the RBS means
# singleton(...), so the declaration is ignored. The walk that decides
# whether every value of the method is a class stopped at a rescue modifier, kept the
# declaration, and the C return `sp_VlRescueModifierStory *` was handed an sp_Class, which
# the C compiler refused.
class VlRescueModifierStory
  def self.none = "VlRescueModifierStory.none"
end

class VlRescueModifierSearch
  def initialize(what) = @what = what

  def searched_model
    (raise ArgumentError, 'x' if @what == :stories; VlRescueModifierStory) rescue VlRescueModifierStory
  end
end

p VlRescueModifierSearch.new(:stories).searched_model.none
p VlRescueModifierSearch.new(:comments).searched_model.none
