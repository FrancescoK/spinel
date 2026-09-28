# A multiple assignment whose right side is an array known only at run time
# (or a scalar, or a boxed value) stores into every kind of target, not only
# locals and instance variables.

def pair; [1, "x"]; end
def ints; [3, 4].map { |x| x * 2 }; end
def poly(f) = f ? [1, 2] : "s"

$a, $b = pair
p $a, $b
$c, $d = [3, 4].map { |x| x * 2 }
p $c, $d
$n = 0
$n, $m = pair
p $n, $m
$e, *$f = [1, 2, 3].map { |v| v }
p $e, $f
*$q, $w = ints
p $q, $w
x = ($g, $h = ints)
p x, $g, $h

$p1, $p2 = poly(true)
p $p1, $p2
$p3, $p4 = poly(false)
p $p3, $p4

$s1, $s2 = 1
p $s1, $s2

class K
  @@a = nil; @@b = nil
  def self.go
    @@a, @@b = [7, 8].map { |x| x }
    p @@a, @@b
  end
end
K.go

h = {}
h[:a], h[:b] = pair
p h
h[:c], h[:d] = poly(true)
p h
h[:e], h[:f] = 2
p h
sh = {}
sh["a"], sh["b"] = ints
p sh
ia = [0, 0]
ia[0], ia[1] = ints
p ia

class O; attr_accessor :x, :y; end
o = O.new
o.x, o.y = 3
p o.x, o.y
o.x, *z, o.y = ints
p o.x, z, o.y

$r, $wr = IO.pipe
$wr.puts "hi"
$wr.close
p $r.gets
