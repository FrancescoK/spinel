# A generated reader on a receiver read out of a container goes through the
# dispatch switch, which has an arm for it: a private or protected reader
# refuses a call from outside, as a private method does, and an undefined
# one is undefined. `members` beside a Struct is such a reader too.
Pt = Struct.new(:x)

class Lobby
  attr_reader :members, :secret
  def initialize = (@members = 7; @secret = 8)
  protected :members
  private :secret
  def peer(o) = o.members
  def own = [self.members, secret]
end

class Hall
  attr_reader :members, :secret
  def initialize = (@members = 9; @secret = 10)
  undef members
  undef secret
end

def try
  p yield
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end

items = [Lobby.new, Hall.new, Pt.new(1)]
try { items[0].members }
try { items[0].secret }
try { items[0].public_send(:members) }
p items[0].send(:secret)
p items[0].peer(items[0])
p items[0].own
try { items[1].members }
try { items[1].secret }
p items[2].members

# a subclass that declares the readers again after its parent undefined them
class Kid < Hall
  attr_reader :members, :secret
end

kid = [Kid.new, Pt.new(2)][0]
try { kid.members }
try { kid.secret }

# a subclass that only inherits them finds them undefined; one whose
# reopened body aliases the names below the `undef` answers the alias
class Annex < Hall; end
class Wing < Hall
  attr_reader :payload
  def initialize = (super; @payload = 11)
end
class Wing
  alias members payload
  alias secret payload
end

rest = [Annex.new, Wing.new, Pt.new(3)]
try { rest[0].members }
try { rest[0].secret }
try { rest[1].members }
try { rest[1].secret }

# a Struct's member keeps its place below an `undef` of its reader
class PtSub < Pt
  undef x
end
class PtKid < PtSub; end
[PtKid, Pt].each { |k| p k.new(4).to_a }
