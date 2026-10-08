# A return declared as an instance type on a method that returns the class
# itself: the RBS means singleton(...). A single class used to pin the C
# return to `sp_SrcStory *` and return the sp_Class into it, which the C
# compiler refused without a word about the signature; a union compiled, but
# typed every call on the value from the instance side. Both now warn, and
# the single-class declaration is ignored.
# spinel: rbs-seed-check
class SrcStory
  def self.none = "SrcStory.none"
end

class SrcComment
  def self.none = "SrcComment.none"
end

class SrcRelation
  def none = "relation none"
end

class SrcSearch
  def initialize(what) = @what = what

  def one_model = SrcStory

  def searched_model
    if @what == :stories
      SrcStory
    else
      SrcComment
    end
  end
end

p SrcSearch.new(:stories).one_model.none
p SrcSearch.new(:stories).searched_model.none
p SrcSearch.new(:comments).searched_model.none
p SrcRelation.new.none
