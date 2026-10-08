# Builtin receiver-return rules must not replace a String override's result,
# whether the receiver is an append chain, a shared slot or a reader call.
# spinel: gc-minor
class String
  def strip! = +"other"
  def upcase! = +"upper"
end

s = +"a "
t = (s << "x").strip!
p t
p t.equal?(s)
u = s
r = (u << "y").strip!
r << "!"
p r, s

s = +"b"
u = s
r = (u << "x").upcase!
r << "!"
p r, s, r.equal?(s)

module BangOverride
  def chomp! = +"prepended"
end
class String
  prepend BangOverride
end
s = +"c"
u = s
r = (u << "x").chomp!
r << "!"
p r, s, r.equal?(s)

# The direct local return precedes the append-chain return in the helper.
s = +"local"
u = s
u << "!"
local_result = s.strip!
p local_result, s, local_result.equal?(s), s.strip!

$s = +"global"
$s << "!"
global_result = $s.strip!
p global_result, $s, $s.strip!

S = +"constant"
S << "!"
constant_result = S.strip!
p constant_result, S

class BangHolder
  attr_reader :s
  def read
    puts "read"
    @s
  end
  def initialize = @s = +"ivar"
  def strip_ivar
    @s << "!"
    r = @s.strip!
    p r, @s
  end
  @@s = +"cvar"
  def self.strip_cvar
    @@s << "!"
    r = @@s.strip!
    p r, @@s
  end
end
h = BangHolder.new
h.strip_ivar
reader_result = h.s.strip!
p reader_result, h.s, h.s.strip!
read_result = h.read.strip!
p read_result, h.s
BangHolder.strip_cvar
