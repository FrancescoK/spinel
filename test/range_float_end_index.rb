# An Integer Range whose end is written as a Float, used as an index span,
# converts each end with to_int as CRuby does: the end truncates toward zero
# and keeps its exclusivity, so a[1...2.5] is a[1...2] and a[0..-2.5] is
# a[0..-2]. The span read the walk bounds instead (floor of the end, the
# exclusivity folded in), so a[1...2.5] took two elements and a[0..-2.5]
# stopped one short. Arrays, Strings, Symbols, Integers and MatchData, through
# [] / slice / slice! / []= / fill / values_at / byteslice, typed or boxed.

def t(s)
  r = yield
  puts "#{s}: #{r.inspect}"
rescue StandardError => e
  puts "#{s}: #{e.class}: #{e.message}"
end

def run(r, i)
  a = [10, 20, 30, 40, 50]
  s = "abcdef"
  t("#{i} a[]") { a[r] }
  t("#{i} a.slice") { a.slice(r) }
  t("#{i} a.values_at") { a.values_at(r) }
  t("#{i} s[]") { s[r] }
  t("#{i} s.slice") { s.slice(r) }
  t("#{i} byteslice") { s.byteslice(r) }
  t("#{i} a[]=") { b = a.dup; b[r] = 0; b }
  t("#{i} s[]=") { b = s.dup; b[r] = "Z"; b }
  t("#{i} fill") { b = a.dup; b.fill(0, r) }
  t("#{i} slice!") { b = a.dup; [b.slice!(r), b] }
  t("#{i} s.slice!") { b = s.dup; [b.slice!(r), b] }
  t("#{i} int[]") { 0b11111111[r] }
  t("#{i} md[]") { "abcdef".match(/(.)(.)(.)(.)/)[r] }
end
run((1..2.5), 0)
run((1...2.5), 1)
run((1...3.0), 2)
run((0..-2.5), 3)
run((0...-2.5), 4)
run((1..3), 5)

puts "-- boxed"
mix = [(1..2.5), (1...2.5), (0..-2.5), "x", [1]]
arr = [[10, 20, 30, 40, 50], "abcdef"][0]
str = [[10], "abcdef"][1]
num = [255, "x"][0]
sym = [:symbol, 1][0]
3.times do |i|
  r = mix[i]
  t("#{i} arr[]") { arr[r] }
  t("#{i} str[]") { str[r] }
  t("#{i} sym[]") { sym[r] }
  t("#{i} int[]") { num[r] }
end
