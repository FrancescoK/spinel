# A store through a box widens the Hash a global holds, as it does an ivar's:
# every write of the global is in sight, read in a method or through an alias.
# spinel: gc-minor
def put(x)
  [$hp, 1][ARGV.size][0] = x
end
$hp = {0 => 0}
put("s")
p $hp

$two = {a: 1}
$two = {"b" => 2} if ARGV.size == 0
[$two, 1][ARGV.size][3] = 4.5
p $two

alias $other $al
$al = {1 => 1}
[$other, 1][ARGV.size][:k] = "v"
p $al, $other

def keep(h) = [h, 1][ARGV.size].store(0, :sym)
$kept = {0 => 0}
keep($kept)
p $kept

# The value read back out of the widened Hash feeds the next store.
$g = {"x" => 0}
box = [$g, nil][ARGV.size]
box["x"] = "y"
v = $g["x"]
$h = {1 => 1}
[$h, 1][ARGV.size][1] = v
p $g, $h, v

# A store other than a plain write leaves the global unbounded. These
# stores do not run, and must not widen the Hash.
$either = {c: 3}
$either ||= {d: 4}
[$either, 1][ARGV.size][0] = 5 if ARGV.size == 99
p $either

$pair, $rest = {e: 5}, 1
[$pair, 1][ARGV.size][0] = 5 if ARGV.size == 99
p $pair
