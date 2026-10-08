# A return declared singleton(...) -- or a union of them -- is a Class value:
# the declaration agrees with a body returning the classes, and the seed
# check says nothing (#5036).
# spinel: rbs-seed-check
class SgStory
  def self.none = "stories"
end
class SgComment
  def self.none = "comments"
end
class SgSearch
  def initialize(what) = @what = what
  def searched_model
    if @what == :stories
      SgStory
    else
      SgComment
    end
  end
  def one = SgStory
end
puts SgSearch.new(:stories).searched_model.none
puts SgSearch.new(:comments).searched_model.none
puts SgSearch.new(:x).one.none
