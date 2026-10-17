# spinel: rbs-seed-run
# A return declared as an instance type on a method that answers the class
# itself through a `case`/`in` (seed_ret_instance_for_class.rb): the RBS means
# singleton(...), so the declaration is ignored. The walk that decides
# whether every value of the method is a class stopped at a `case`/`in`, kept the
# declaration, and the C return `sp_VlCaseInStory *` was handed an sp_Class, which
# the C compiler refused.
class VlCaseInStory
  def self.none = "VlCaseInStory.none"
end

class VlCaseInSearch
  def initialize(what) = @what = what

  def searched_model
    case @what
    in :stories then VlCaseInStory
    else VlCaseInStory
    end
  end
end

p VlCaseInSearch.new(:stories).searched_model.none
p VlCaseInSearch.new(:comments).searched_model.none
