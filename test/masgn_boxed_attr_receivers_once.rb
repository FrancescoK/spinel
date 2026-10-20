# spinel: gc-stress
# The attribute targets of a multiple assignment whose receivers are boxed
# values (a call that answers one of two classes) evaluate their receivers once,
# before the right side and left to right, as the other targets do, beside
# index targets, consts, ivars and globals, and a splat.
# poly receivers, multi-key []=, consts/ivars/gvars, string-keyed hash
$log = []
class K
  attr_accessor :x, :y
end
class J
  attr_accessor :x, :y
end
def pr(t, i); $log << "recv #{t}"; [K.new, J.new][i]; end
def k(t); $log << "key #{t}"; t; end
def rhs; $log << "rhs"; [1, 2, 3]; end
pr("a", 0).x, pr("b", 1).y, pr("c", 0).x = rhs
puts $log
$log.clear
SH = {}
def sh(t); $log << "sh #{t}"; SH; end
sh("1")["a#{k('k1')}"], sh("2")[k("k2")], pr("d", 1).x = rhs
puts $log
p SH
$log.clear
AA = [[0, 0], [0, 0]]
def aa(t); $log << "aa #{t}"; AA; end
aa("x")[k(0)][k(1)], aa("y")[k(1)][k(0)] = rhs
puts $log
p AA
$log.clear
module M; end
class C
  def go
    @iv, $gv, loc, pr("e", 0).x, *@rest = rhs
    p [@iv, $gv, loc, @rest]
  end
end
C.new.go
M::Q, $g2, pr("e2", 1).y = rhs
p [M::Q, $g2]
puts $log
$log.clear
PA = [0, 1]
def pa(t); $log << "pa #{t}"; [PA, {}][0]; end
pa("p")[k(0)], pa("q")[k(1)] = rhs
puts $log
p PA
$log.clear
x = (pr("r", 0).x, pr("s", 1).y = 4) rescue p($!)
p x
puts $log
