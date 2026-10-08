# Prepending to an append chain keeps the existing shared String handle.
# spinel: gc-minor
def local_prepend
  s = +"a"
  t = s
  t << "!"
  r = (s << "x").prepend("p", "q")
  p s, t, r, r.equal?(s)
  p (s.concat("y") << "z").prepend("r")
  p t
end
local_prepend

class PrependHolder
  def run
    @s = +"a"
    t = @s
    t << "!"
    r = (@s << "x").prepend("p", "q")
    p @s, t, r, r.equal?(@s)
  end
end
PrependHolder.new.run
