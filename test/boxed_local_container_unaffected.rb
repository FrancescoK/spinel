# Shapes beside the refused boxed local in a container (a String a boxed
# local holds, changed through a container element): a plain String local,
# a container passed through a method, a boxed local holding an Array, a
# Hash or a number, reads or replacements of the element, and a local bound
# from a literal's element whose String no other name reads or is frozen, so
# each compiles and answers as CRuby.
k = ARGV.size
s1 = +"s"; [s1][0].prepend("a"); p s1
a2 = [+"x", 1]; a2[0].insert(0, "<"); a2[0].concat(">", "!"); a2[0].prepend("a"); p a2
s3 = +"t"; r3 = [s3, 2]; r3[k].concat("!"); p s3, r3
def m4(s) = [s][0].prepend("q")
x4 = +"x"; m4(x4); p x4
y4 = [+"y", 1][k]; m4(y4); p y4
def mk5(s) = [s, 1]
s5 = [+"xy", 1][k]; a5 = mk5(s5); a5[0].prepend("q"); a5.first.concat("!"); p s5, a5
s6 = [[1], 2][k]; [s6][0] << 3; p s6
s7 = [{a: 1}, 2][k]; [s7][0][:b] = 2; p s7
s8 = [1, 2.5][k]; a8 = [s8]; a8[0] += 1; p a8
s9 = [+"xy", 1][k]; a9 = [s9]; p a9[0].upcase, s9
s10 = [+"xy", 1][k]; [s10].each { |e10| p e10 + "!" }; p s10
s11 = [+"xy", 1][k]; a11 = [s11, 2]; a11[0] = a11[0] + "!"; p s11, a11
s12 = [+"xy", 1][k]; s12 << "!"; p [s12]
s13 = +"xy"; t13 = [s13][0]; t13 << "!"; p t13
s14 = +"xy"; t14 = [s14][0]; p t14.upcase, s14
s15 = +"xy"; t15 = [s15, 1][0]; t15 = t15 + "!"; p s15, t15
a16 = [[1], 2]; t16 = [a16][0]; t16 << 3; p a16
s17 = [[1], 2][k]; t17 = [s17][0]; t17 << 3; p s17
s18 = +"xy"; t18 = [s18.dup][0]; t18 << "!"; p s18, t18
s19 = +"xy"; s19.freeze; t19 = [s19][0]; begin; t19 << "!"; rescue FrozenError; p :frozen; end; p s19
