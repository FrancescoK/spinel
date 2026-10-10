# spinel: share
# spinel: gc-minor
# spinel: gc-stress
# A block a reopening's proc form yields a String to that matches it against a
# Regexp leaves the bytes in the match globals. They are the String as it was
# matched, whatever it becomes afterwards and whatever the collector does.
class String
  def pm(a) = yield(a)
end
def grow(s)
  s << ("x" * 3000)
  s.replace("Z" * 6000)
  junk = []
  300.times { |i| junk << ("j" * 70 + i.to_s) }
  GC.start
end
def fresh
  s = +"hello"
  s << " world"
  s
end

s = fresh; t = s
(+"ab").pm(s) { |v| v =~ /(h.*)/; 0 }
grow(s)
p($~ ? [$~[0], $~[1], $~.pre_match] : nil)
s = fresh; t = s
(+"ab").pm(s) { |v| v.index(/(o)/); 0 }
grow(s)
p($~ ? [$~[0], $~[1], $~.pre_match] : nil)
s = fresh; t = s
(+"ab").pm(s) { |v| v[/(w.*)/]; 0 }
grow(s)
p($~ ? [$~[0], $~[1], $~.pre_match] : nil)
s = fresh; t = s
(+"ab").pm(s) { |v| v.slice(/(l+)/); 0 }
grow(s)
p($~ ? [$~[0], $~[1], $~.pre_match] : nil)
s = fresh; t = s
(+"ab").pm(s) { |v| v.scan(/(o)/); 0 }
grow(s)
p($~ ? [$~[0], $~[1], $~.pre_match] : nil)
s = fresh; t = s
(+"ab").pm(s) { |v| v.sub(/(e)/, "E"); 0 }
grow(s)
p($~ ? [$~[0], $~[1], $~.pre_match] : nil)
s = fresh; t = s
(+"ab").pm(s) { |v| v.gsub(/(o)/, "0"); 0 }
grow(s)
p($~ ? [$~[0], $~[1], $~.pre_match] : nil)
s = fresh; t = s
(+"ab").pm(s) { |v| v.start_with?(/(h)/); 0 }
grow(s)
p($~ ? [$~[0], $~[1], $~.pre_match] : nil)
s = fresh; t = s
(+"ab").pm(s) { |v| v.match?(/(h)/); 0 }
grow(s)
p($~ ? [$~[0], $~[1], $~.pre_match] : nil)
