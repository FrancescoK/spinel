# Compiled with --defer-refusals: a refused call as the last statement of a
# block spliced as a condition (find's) raises NotImplementedError when the
# block runs; the C keeps a value of the call's type there, as void is not
# one.
# spinel: defer-refusals: 2:a NotImplementedError done
def pick(xs) = xs.find { |s| s.unicode_normalize(:nfc) == "b" }

puts "a"
begin
  pick(%w[a b])
rescue NotImplementedError => e
  puts e.class
end
puts "done"
"a".unicode_normalize(:nfd)
puts "not reached"
