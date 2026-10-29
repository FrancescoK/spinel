# split on a receiver of run-time type with a Regexp separator of run-time
# type: the boxed arm read the separator as a String and raised TypeError.
# Rack's QueryParser splits its query (a boxed String) this way.

def cut(s, sep) = s.split(sep)
def cut2(s, sep, n) = s.split(sep, n)

p cut("a&b&&", /&/), cut("a b", " "), cut("a  b", nil)
p cut2("a&b&c", /&/, 2), cut2("a; b;c", /; */, 0), cut2("a,b", ",", -1)
p((cut(1, /x/) rescue $!.class), (cut2(1, /x/, 1) rescue $!.class))

# a separator held in a Hash, as Rack's COMMON_SEP
SEP = { "&" => /& */n }
def pairs(qs, sep) = qs.split(sep ? SEP[sep] || /[#{sep}] */n : /& */n, 10)
p pairs("a=1& b=2", "&"), pairs("a=1;b=2", ";"), pairs("x&y", nil)
p((pairs(1, nil) rescue $!.class))

# a separator that is neither: CRuby's "expected Regexp"
p((cut("ab", 1) rescue $!.message))
p((cut2("ab", :a, 2) rescue $!.message))

# the separator is read once, then the limit
$n = 1
def sep_once = ($n += 1; [/b/, "b"][0])
p cut2("abcbd", sep_once, ($n *= 10; 2)), $n

# the other separators the boxed slot holds: a capture group, nil with a
# limit, a mutable String, an object with #to_str
class Comma; def to_str = ","; end
sb = +""; sb << ","
p cut("a1b2c", /(\d)/), cut2("a b c", nil, 2), cut("a,b", sb), cut2("a,b,c", [Comma.new, 1][0], 2)

# a limit of 1 answers the whole String before the separator is looked at
p cut2("ab", :a, 1), cut2(" a b", nil, 1), cut2("a b", /x/, 1)
# the separator is read after the limit, which may append to it
sb2 = +""; sb2 << ","
p cut2("a,b;c", sb2, (sb2 << ";"; 5))
