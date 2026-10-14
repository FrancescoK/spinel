# spinel: share
# spinel: gc-minor
# A frozen literal stored in an Array of shared Strings keeps its identity;
# a String built or changed elsewhere does too.
lit = "lit"
f = [+"first"]
f << lit
f.push("lit")
p f[1].equal?(lit), f[1].frozen?, f[2].equal?(lit), f[0].frozen?
g = [lit, +"g"]
p g[0].equal?(lit)
f[0] << "!"
p f
begin
  f[1] << "x"
rescue => e
  p e.class
end
h = ["a", +"b"]
h[1] << "c"
p h, h[0].frozen?
