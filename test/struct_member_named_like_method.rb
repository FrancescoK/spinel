# A member accessor answers before the Struct / Data method of the same
# name, as in CRuby: Struct.new(:members) defines #members on the class.
class Sock; end
Room = Struct.new(:lock, :members)
room = Room.new(Mutex.new, {})
room.members[Sock.new] = 1
room.members[Sock.new] = 2
p room.members.length
p room.members.values
p Room.members

Row = Struct.new(:values, :to_a, :deconstruct, :to_h)
row = Row.new([1, 2], "a", :d, 3.5)
p row.values
p row.to_a
p row.deconstruct
p row.to_h

Named = Struct.new(:inspect, :to_s)
n = Named.new("i", "s")
p n.inspect
puts n.to_s
Counted = Struct.new(:inspect, :to_s)
k = Counted.new(1, 2)
p k.inspect
p k.to_s
Measure = Data.define(:inspect)
p Measure.new(inspect: 3.5).inspect

Point = Data.define(:x, :members, :to_h)
pt = Point.new(x: 1, members: [:a], to_h: 7)
p pt.members
p pt.to_h + 1
p Point.members

# A subclass keeps the members of the Struct it extends.
class Team < Struct.new(:name, :members)
  def size = members.size
end
t = Team.new("core", %w[a b c])
p t.members
p t.size

# A method written in the block still overrides both.
Box = Struct.new(:members) do
  def members = [:overridden]
end
p Box.new(1).members

# Without such a member the builtins are unchanged.
Plain = Struct.new(:a, :b)
pl = Plain.new(1, 2)
p pl.members
p pl.to_a
p pl.to_h
