class K; @@v = +"v"; def self.v = @@v; def self.mut = @@v << "!"; end
$g = +"g"
lv = K.v
K.mut
p lv.equal?(K.v)
a = [$g]
a[0] << "?"
p a[0].equal?($g)
