# Flag-only: Array.new fills its typed slots with the shared static seed.
# All elements and both names keep the same object, including frozen seeds.
$direct_seed = +"direct"
t = Array.new(2, $direct_seed)[1]
p $direct_seed.equal?(t), $direct_seed.object_id == t.object_id
$direct_seed << "!"
p t
t.gsub!("d", "D")
p $direct_seed
$direct_frozen = "frozen"
u = Array.new(2, $direct_frozen)[1]
p $direct_frozen.equal?(u), $direct_frozen.object_id == u.object_id
begin
  u.gsub!("f", "F")
rescue FrozenError => e
  p e.class
end
p [$direct_frozen, u]
$fill_frozen = "abc"
a = Array.new(2, $fill_frozen)
p a[0].equal?($fill_frozen), a[0].object_id == $fill_frozen.object_id
p a[0].equal?(a[1]), a[1].frozen?
begin
  a[1].gsub!("a", "o")
rescue FrozenError => e
  p e.class
end
p [$fill_frozen, a[0], a[1]]
$fill_mutable = +"abc"
b = Array.new(2, $fill_mutable)
p b[0].equal?($fill_mutable), b[0].object_id == $fill_mutable.object_id
$fill_mutable << "!"
p b
b[1].replace("new")
p [$fill_mutable, b[0], b[1]]
class FillHolder
  SEED = +"constant"
  @@seed = +"class"
  def run
    @seed = +"ivar"
    c = Array.new(2, SEED)
    d = Array.new(2, @@seed)
    e = Array.new(2, @seed)
    c[0] << "!"
    d[0] << "!"
    e[0] << "!"
    p SEED.equal?(c[1]), @@seed.equal?(d[1]), @seed.equal?(e[1])
    p SEED.object_id == c[1].object_id
    p @@seed.object_id == d[1].object_id
    p @seed.object_id == e[1].object_id
    p SEED, @@seed, @seed
  end
end
FillHolder.new.run
