# spinel: gc-stress
# The calls made before a nil receiver's NoMethodError: a nested, a post-splat
# and a splat target each evaluate both receivers, once, and raise at the store.
class K; attr_accessor :x; end
class J; attr_accessor :x; end
$n = 0
def pk(i) = ($n += 1; [K.new, J.new, nil][i])
def tk(i) = ($n += 1; i == 2 ? nil : K.new)
[[0, 1], [1, 2], [2, 0]].each do |i, j|
  $n = 0
  begin
    (pk(i).x, pk(j).x), z = [1, 2], 3
    print "ok "
  rescue NoMethodError => e
    print e.message, " "
  end
  p $n
  $n = 0
  begin
    z, *pk(i).x, pk(j).x = 1, 2, 3
    print "ok "
  rescue NoMethodError => e
    print e.message, " "
  end
  p $n
  $n = 0
  begin
    z, (tk(i).x, *tk(j).x) = 1, [2, 3]
    print "ok "
  rescue NoMethodError => e
    print e.message, " "
  end
  p $n
end
