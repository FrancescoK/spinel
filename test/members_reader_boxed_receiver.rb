# `members` on a boxed receiver (a value read out of a container) answered
# Struct#members, the member names, even when the class reads a value of
# its own under that name: a Struct member named `members`, or an
# attr_reader. Indexing the answer with an object key then refused to
# compile (no implicit conversion of Sock into Integer). A reader of the
# name answers now, and a Struct without one still answers its names.
# No method named `members` is defined anywhere here: one would have taken
# the dispatch already.
class Sock; end

Room = Struct.new(:lock, :members)
ROOMS = {}
def room_for(id) = (ROOMS[id] ||= Room.new(Mutex.new, {}))
room_for(1).members[Sock.new] = 1
room_for(1).members[Sock.new] = 2
p room_for(1).members.length

class Lobby
  attr_reader :members
  def initialize = (@members = {})
end
lobby = [Lobby.new][0]
lobby.members[Sock.new] = 1
p lobby.members.length

Point = Struct.new(:x, :y)
Pos = Data.define(:q)
[Point.new(1, 2), Lobby.new, Room.new(nil, [:m]), Pos.new(q: 3)].each { |o| p o.members }
p [Point, 1][0].members

# a Struct or Data *class* read out of a container answers its member names,
# also when its instances read a member named `members`
Pair = Data.define(:members, :n)
p [Room, 1][0].members
p [Pair, 1][0].members
p [Pair.new(members: [7], n: 8), 1][0].members
