# Shapes beside the refused String bindings (a pattern binding, `alias $b
# $a`, a constant written from a variable or by `||=`, an instance_eval
# block's instance variable, an instance variable a superclass and a
# subclass both name, one written from another object's reader): the String
# is fresh, frozen, a copy or never mutated in place, or one class names
# it, so each compiles and answers as CRuby.
s1 = +"abc"
case [s1]
in [t1] then p t1.upcase
end
p s1
case [+"abc"]
in [t2] then t2 << "!"; p t2
end
s3 = "abc"
case [s3]
in [t3] then (t3 << "!" rescue p :fz)
end
p s3
s4 = +"abc"
case [s4]
in [t4] then t4 = t4 + "!"; p t4
end
p s4
alias $b5 $a5
$a5 = +"x"; p $b5
$b5 << "!"; p $a5
X6 = +"abc"; X6 << "!"; p X6
module M7; X = +"abc"; end
M7::X << "!"; p M7::X
module M8; end
s8 = +"abc"; M8::Y ||= s8; p M8::Y
class K9; def k = @k; end
k9 = K9.new; s9 = +"abc"; k9.instance_eval { @k = s9 }; p k9.k
k10 = K9.new; k10.instance_eval { @k = +"z" }; k10.k << "!"; p k10.k
class A11; def initialize(x) = (@k = x); def bang = @k << "!"; end
s11 = +"abc"; A11.new(s11).bang; p s11
class A12; def initialize(x) = (@k = x); end
class B12 < A12; def k = @k; end
s12 = +"abc"; p B12.new(s12).k
class A13; def initialize = (@k = +"a"); end
class B13 < A13; def bang = @k << "!"; def k = @k; end
b13 = B13.new; b13.bang; p b13.k
class K14; attr_accessor :v; def bang = @v << "!"; end
k14 = K14.new; k14.v = +"a"; k14.bang; p k14.v
class K15; attr_accessor :v; end
k15 = K15.new; k15.v = +"a"; k15b = K15.new; k15b.v = k15.v; p k15b.v
k16 = K14.new; k16.v = +"a"; k16b = K14.new; k16b.v = k16.v.dup; k16b.bang; p k16.v, k16b.v
