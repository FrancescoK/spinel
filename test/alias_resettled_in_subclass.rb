# An alias a subclass makes again over its own method answers for that
# subclass and the classes below it: a module one of those includes, with
# no method of the aliased name, changes nothing about the alias above, and
# the program is not refused for it. activesupport aliases to_formatted_s to
# to_fs in Date and again in DateTime over DateTime's own to_fs, and
# tzinfo's DateTimeWithOffset < DateTime includes a module.
class Base
  def to_fs = "base"
  alias_method :to_formatted_s, :to_fs
end
class Mid < Base
  def to_fs = "mid"
  alias_method :to_formatted_s, :to_fs
end
module WithOffset
  def offset = 9
end
class Leaf < Mid
  include WithOffset
end
puts Leaf.new.to_formatted_s, Leaf.new.to_fs, Leaf.new.offset, Mid.new.to_formatted_s, Base.new.to_formatted_s
