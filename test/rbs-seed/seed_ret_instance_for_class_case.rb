# spinel: rbs-seed-run
# A return declared as an instance type on a method that answers the class
# itself through a `case`/`when` (seed_ret_instance_for_class.rb): the RBS means
# singleton(...), so the declaration is ignored. The walk that decides
# whether every value of the method is a class stopped at a `case`/`when`, kept the
# declaration, and the C return `sp_VlCaseStory *` was handed an sp_Class, which
# the C compiler refused.
class VlCaseStory
  def self.none = "VlCaseStory.none"
end

class VlCaseSearch
  def initialize(what) = @what = what

  def searched_model
    case @what
    when :stories then VlCaseStory
    else VlCaseStory
    end
  end
end

p VlCaseSearch.new(:stories).searched_model.none
p VlCaseSearch.new(:comments).searched_model.none
