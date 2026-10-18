# spinel: rbs-seed-run
# A return declared as an instance type on a method that answers the class
# itself through a `begin` with a rescue clause (seed_ret_instance_for_class.rb): the RBS means
# singleton(...), so the declaration is ignored. The walk that decides
# whether every value of the method is a class stopped at a `begin` with a rescue clause, kept the
# declaration, and the C return `sp_VlBeginStory *` was handed an sp_Class, which
# the C compiler refused.
class VlBeginStory
  def self.none = "VlBeginStory.none"
end

class VlBeginSearch
  def initialize(what) = @what = what

  def searched_model
    begin
      raise ArgumentError, 'x' if @what == :stories
      VlBeginStory
    rescue ArgumentError
      VlBeginStory
    end
  end
end

p VlBeginSearch.new(:stories).searched_model.none
p VlBeginSearch.new(:comments).searched_model.none
