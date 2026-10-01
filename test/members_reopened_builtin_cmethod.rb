# `members` on a boxed Struct class, when the only class method of that name
# is on a reopened builtin, which gets no class-side arm: the Struct class
# still answers its member names, and is not read as one of its instances.
class String
  def self.members = 0
end

Room = Struct.new(:members)
p [Room.new(7), Room, 0][1].members
p [Room.new(7), Room, 0][0].members
