# String#upcase / downcase / capitalize / swapcase, their `!` forms and
# Symbol's check their case-mapping options before they map, or, for a `!`
# form, before they check frozen, as CRuby does: :ascii alone, :turkic and
# :lithuanian alone or together, :fold for downcasing only. Anything else is
# ArgumentError, where the String was mapped regardless. The receiver is
# evaluated first, as CRuby evaluates it before the method runs.
def t
  yield
rescue ArgumentError, FrozenError => e
  p [e.class, e.message]
end
t { p "abc".upcase(:fold) }
t { p "abc".upcase(:invalid_option) }
t { p "i".upcase(:turkic, :ascii) }
t { p "ab".upcase(:lithuanian, :ascii) }
t { p "abc".upcase(:ascii, :turkic) }
t { p "ab".upcase(:a, :b, :c) }
t { p "ab".upcase(1) }
t { p "ab".upcase("ascii") }
t { p "ab".upcase(nil) }
t { p "ABC".downcase(:invalid_option) }
t { p "ABC".downcase(:fold, :ascii) }
t { p "ABC".downcase(:turkic, :turkic) }
t { p "abc".capitalize(:fold) }
t { p "abc".swapcase(:fold) }
t { p :abc.upcase(:fold) }
t { p :abc.downcase(:x) }
t { a = "abc"; a.capitalize!(:fold) }
t { a = +"abc"; a.upcase!(:invalid_option); p a }
t { a = "abc".freeze; a.swapcase!(:x) }
t { a = "ABC"; a.downcase!(:fold) }
$log = []
def srcs(s) = ($log << s; s)
def srcy(s) = ($log << s; s)
t { p srcs("abc").upcase(:fold) }
t { p srcy(:abc).capitalize(:x) }
t { srcs(+"def").swapcase!(:x) }
p $log
o = [:fold, :ascii][ARGV.size]
t { p "aBc".upcase(o) }
t { p "aBc".downcase(o) }
p "aBc".upcase(:ascii), "aBc".downcase(:fold), "aBc".swapcase(:turkic), "aBc".capitalize(:lithuanian, :turkic)
p "aBc".upcase(:turkic, :lithuanian), :aBc.swapcase(:ascii)
b = +"aBc"; b.downcase!(:fold); p b
# a block is ignored, and the options are checked all the same
t { p "abc".upcase(:invalid) { nil } }
t { p :abc.downcase(:x) { 1 } }
p "abc".upcase(:ascii) { nil }
# an option with a side effect runs once
$n = 0
def next_opt = ($n += 1; :ascii)
p "abc".upcase(next_opt), :xY.downcase(next_opt), $n
s2 = +"aBc"; s2.swapcase!(next_opt); p s2, $n
