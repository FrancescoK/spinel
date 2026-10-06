# Shapes beside the refused String hand-over routes (then/tap, String(),
# unary +, begin/rescue values, yield's block value, a proc's answer,
# Thread#value, break/throw/catch, a method's answer, a raised message,
# Hash#default=): the String is frozen, never mutated in place, a copy, or
# fresh, or no other name reads it, so each compiles and answers as CRuby.
s1 = "abc"; r1 = s1.then { |x1| x1 }; begin; r1 << "!"; rescue FrozenError; p :fz1; end; p s1
s2 = +"abc"; s2.freeze; r2 = String(s2); begin; r2 << "!"; rescue FrozenError; p :fz2; end
s3 = +"abc"; r3 = String(s3); p r3, s3, r3.equal?(s3)
s4 = +"abc"; x4 = begin; s4; rescue; nil; end; p x4.upcase, s4
s5 = +"abc"; x5 = begin; s5.dup; rescue; nil; end; s5 << "!"; p x5
class K6
  def set = (@a = yield)
  def a = @a
end
o6 = K6.new; s6 = +"abc"; o6.set { s6 }; p o6.a, s6
o7 = K6.new; o7.set { +"z" }; o7.a << "!"; p o7.a
s8 = +"abc"; pr8 = proc { s8 }; p pr8.call.size, s8
pr9 = proc { +"q" }; t9 = pr9.call; t9 << "?"; p t9
s10 = +"abc"; r10 = loop { break s10 }; p r10, s10
s11 = +"abc"; r11 = catch(:t) { throw :t, s11.dup }; r11 << "!"; p s11, r11
s12 = +"abc"; r12 = loop { break s12.upcase }; r12 << "!"; p s12, r12
s13 = +"abc"; r13 = Thread.new { s13.upcase }.value; r13 << "!"; p s13, r13
class K14
  def self.set(v) = (@@g = v)
  def self.g = @@g
end
s14 = +"abc"; K14.set(s14); p K14.g
s15 = +"abc"
begin; raise ArgumentError, s15; rescue => e15; p e15.message; end
p s15
h16 = {}; h16.default = "d"; p h16[:m]
h17 = {}; s17 = +"d"; h17.default = s17; p h17[:m], s17
h18 = {}; h18.default = +"d"; h18[:a] = +"x"; p h18[:a] + "!", h18[:m]
s19 = +"abc"; r19 = s19.then { |x19| x19 + "!" }; s19 << "?"; p r19
s20 = +"abc"; r20 = s20.then { |x20| x20.upcase }; r20 << "!"; p s20, r20
s21 = +"abc"; r21 = s21.then { |x21| x21 }; r21 << "!"; p r21
s22 = "abc"; r22 = +s22; r22 << "!"; p s22, r22
s23 = +"abc"; s23.tap { |v23| v23 << "!" }; p s23
s24 = +"abc"; r24 = [1].each_with_object(s24) { |i24, acc24| acc24 << "x" }; p s24
def m25 = (y25 = +"a"; yield y25; y25)
r25 = m25 { |v25| v25.size }; r25 << "!"; p r25
def mk26 = (b26 = +""; b26 << "x"; b26)
t26 = mk26; t26 << "!"; p t26
def m27 = (y27 = +"a"; @k27 = y27.dup; y27)
r27 = m27; r27 << "!"; p @k27
