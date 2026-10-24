# A module's own copy of an included method (Mixin includes Note; nothing
# includes Mixin) whose implicit-self call it cannot resolve raises
# NameError there, and a reader inlined over that raise's placeholder
# (`current_part.id`) dereferenced an untyped NULL: the program did not
# compile, though nothing calls that copy (#10079).
class Part
  def initialize(id) = @id = id
  attr_reader :id
end

class Object
  def current_part = Part.new("w1")
end

module Note
  def note
    p({ owner: current_part && current_part.id || "none" })
  end
end

module Mixin
  include Note
end

class Widget
  include Note
end

Widget.new.note
