$g = +"g"
G = +"c"
@i = +"i"
class K; @@v = +"v"; def self.v = @@v; def self.mut = @@v << "!"; end
l = $g; $g << "!"
p l.equal?($g), $g.equal?(l)
lc = G; G << "!"
p lc.equal?(G), G.equal?(lc)
li = @i; @i << "!"
p li.equal?(@i), @i.equal?(li)
lv = K.v; K.mut
p lv.equal?(K.v)
a = [$g]; a[0] << "?"
p a[0].equal?($g), a[0].equal?(l)
h = {i: @i}; h[:i] << "?"
p h[:i].equal?(@i)
p $g.object_id == l.object_id, G.object_id == lc.object_id, @i.object_id == li.object_id
