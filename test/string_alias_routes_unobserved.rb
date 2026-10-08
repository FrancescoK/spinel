# spinel: share
# Shapes beside the String routes that are refused (a global read into a
# local, a method returning its parameter, a bang method's result, `to_s`
# under a rebinding argument, an Array element the element store does not
# see): here no in-place change is observed through the other name, or the
# analysis already shares the String, so each compiles and answers as CRuby.
$g = +"a"; t = $g; t << "!"; p t
$h = "a"; u = $h; u += "!"; p $h, u
def id(x) = x
s1 = +"a"; t1 = id(s1); p t1.equal?(s1)
t2 = id(+"a"); t2 << "!"; p t2
s3 = +"a"; t3 = id(s3); t3 += "!"; p s3, t3
s4 = +"a"; t4 = id(s4.dup); t4 << "!"; p s4, t4
def mk = (b = +"a"; b)
t5 = mk; t5 << "!"; p t5
s6 = +"ab"; r6 = s6.reverse!; r6 << "Z"; p s6
s7 = +"ab "; r7 = s7.strip!; p r7, s7
s8 = +"ab"; v8 = s8.sub!("b", "*"); p [s8, v8]
e9 = +"a"; r9 = e9.to_s << (e9 = +"b"); p r9, e9
e10 = +"a"; q10 = e10; q10 << "!"; r10 = e10 << (e10 = +"b"); p r10, q10
$e = +"a"; r11 = $e.to_s << ($e = +"b"); p r11, $e
s12 = +"a"; a12 = []; a12.concat([s12]); s12 << "!"; p a12
s13 = +"a"; $a13 = []; $a13 << s13; s13 << "!"; p $a13
s14 = +"a"; a14 = []; a14 << (s14 << "y"); s14 << "!"; p a14
s15 = +"a"; a15 = []; a15.push(+"b", s15); s15 << "!"; p a15
s16 = +"a"; a16 = []; a16 << s16; a16[0] << "!"; p s16
# The variable changed after it went into an Array nothing reads again
s17 = +"a"; a17 = []; a17.insert(0, s17); s17 << "!"; p s17
s18 = +"a"; a18 = []; a18.prepend(s18); s18 << "!"; p s18
s19 = +"a"; t19 = +"b"; a19 = []; a19 << t19 << s19; s19 << "!"; p s19
s20 = +"a"; a20 = []; a20.concat([s20]); s20 << "!"; p s20
s21 = +"a"; $a21 = []; $a21 << s21; s21 << "!"; p s21
