# sub and gsub with a Regexp pattern read a Hash built with a default block
# with #[] on each match, so the block runs for a missing key (and may store
# it), its value read with to_s (nil as ""), as CRuby does.
cache = Hash.new { |h, k| h[k] = k.upcase }
p "abc".gsub(/[ab]/, cache), "xyz".gsub(/[ab]/, cache), cache
memo = Hash.new { |h, k| h[k] = k * 2 }
p "abc".sub(/[bc]/, memo), "xyz".sub(/[bc]/, memo), memo
calls = 0
counted = Hash.new { |_, k| calls += 1; k * 2 }
counted["c"] = 7
p "abcc".gsub(/./, counted), calls
p "abc".gsub(/b/, Hash.new { |_, k| nil }), "ab".gsub(/a/, Hash.new { |_, k| :"s#{k}" })
re = /[ab]/
x = "b"
p "abc".gsub(re, cache), "abc".gsub(/#{x}/, memo)
s = +"abc"
s.gsub!(/[ab]/, cache)
p s
v = [1, "abc"][1]
p v.gsub(/a/, cache)

# the block may itself call gsub (a memoized normalization)
def vowels(str)
  m = Hash.new { |h, k| h[k] = k.gsub(/[aeiou]/, {"a" => "4", "e" => "3"}) }
  str.gsub(/\w+/, m)
end
p vowels("hello there apple")
