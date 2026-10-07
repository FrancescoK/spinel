# Flag-only: without the flag each route here hands on a copy.
# Under --share-strings the seal checks every value route into a String
# the rule shares: these are the routes codegen hands the shared handle
# along (a write's then, +s, String(s), begin, loop break, spliced yield,
# conditional, a method's tail read, tap and an answers-self chain; an
# element's then and begin; a mutator's conditional receiver; an
# Enumerator's map block), so each compiles and every name sees the
# change. A container literal a builtin only reads keeps no name for a
# copy, and is let through too.

def id(x) = x
def yv = yield
$cnd = true
class O
  attr_accessor :t
end

s = +"a"; t = s.then { |x| x }; t << "1"; p s
s = +"b"; t = +s; t << "2"; p s
s = +"c"; t = String(s); t << "3"; p s
s = +"d"; t = begin; s; rescue; nil; end; t << "4"; p s
s = +"e"; t = loop { break s }; t << "5"; p s
s = +"f"; t = yv { s }; t << "6"; p s
s = +"g"; t = ($cnd ? s : +"x"); t << "7"; p s
s = +"h"; t = id(s); t << "8"; p s
s = +"i"; t = s.tap { |x| x }; t << "9"; p s
s = +"j"; t = (s << ""); t << "0"; p s
s = +"k"; $g = s.then { |x| x }; $g << "!"; p s
s = +"l"; o = O.new; o.t = ($cnd ? s : nil); o.t << "!"; p s
s = +"m"; @iv = String(s); @iv << "!"; p s
s = +"n"; a = [s.then { |x| x }, String(s)]; a[0] << "!"; p s
s = +"o"
a = [begin
  s
rescue
  nil
end]
a[0] << "!"
p s
s = +"p"; ($cnd ? s : +"x") << "!"; p s
s = +"q"; [1].each_with_index.map { |v, k| id(s) }[0] << "!"; p s
s = +"st"; p [s, s.sub!("t", "T")]
