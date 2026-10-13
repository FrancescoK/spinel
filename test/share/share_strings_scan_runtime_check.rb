# A scan block that keeps and changes its matches, over a subject the share
# facts cannot vouch for (a parameter, a local the method hands on), whose
# block changes Strings in place only by growing or clearing the subject's
# own local: the subject's length is checked after each turn the block
# returns from, and a change raises CRuby's RuntimeError ("string
# modified") at the same turn, with the same matches kept before it.

def untouched(t, acc)
  t.scan(/./) { |m| m << "!"; acc << m }
  acc
end
a1 = +"abc"
p untouched(a1, []), a1

def kept_later(t, acc)
  t.scan(/./) { |m| acc << m }
  acc[0] << "!"
  acc
end
a2 = +"abc"
p kept_later(a2, []), a2

def grows_first(t, acc)
  t.scan(/./) { |m| m << "!"; acc << m; t << "z" if acc.size == 1 }
  acc
rescue RuntimeError => e
  p e.message
  acc
end
a3 = +"abc"
p grows_first(a3, []), a3

def grows_last(t, acc)
  t.scan(/./) { |m| m << "!"; acc << m; t << "z" if acc.size == 3 }
  acc
rescue RuntimeError => e
  p e.message
  acc
end
a4 = +"abc"
p grows_last(a4, []), a4

def clears(t, acc)
  t.scan(/./) { |m| m << "!"; acc << m; t.clear if acc.size == 2 }
  acc
rescue RuntimeError => e
  p e.message
  acc
end
a5 = +"abcd"
p clears(a5, []), a5

def prepends_nothing(t, acc)
  t.scan(/./) { |m| m << "!"; acc << m; t.prepend("") }
  acc
end
p prepends_nothing(+"abc", [])

def grows_then_next(t, acc)
  t.scan(/./) { |m| m << "!"; acc << m; t << "z"; next if acc.size == 1; acc << "after" }
  acc
rescue RuntimeError => e
  p e.message
  acc
end
p grows_then_next(+"abc", [])

def grows_then_breaks(t, acc)
  x = t.scan(/./) { |m| m << "!"; acc << m; t << "z"; break m if acc.size == 1 }
  [x, acc, t]
rescue RuntimeError => e
  p e.message
  acc
end
p grows_then_breaks(+"abc", [])

def value_used(t, acc)
  r = t.scan(/./) { |m| m << "!"; acc << m; t << "z" if acc.size == 2 }
  [r, acc]
rescue RuntimeError => e
  p e.message
  acc
end
p value_used(+"abc", [])

def groups(t, acc)
  t.scan(/(\w)(\d)/) { |x, y| x << "!"; acc << x; t << "q" if acc.size == 1 }
  acc
rescue RuntimeError => e
  p e.message
  acc
end
p groups(+"a1b2", [])

def string_pattern(t, acc)
  t.scan("b") { |m| m << "!"; acc << m; t << "b" if acc.size == 1 }
  acc
rescue RuntimeError => e
  p e.message
  acc
end
p string_pattern(+"abab", [])

def long(t, acc)
  t.scan(/a/) { |m| m << "!"; acc << m; t << "z" if acc.size == 2 }
  acc.size
rescue RuntimeError => e
  p e.message
  acc.size
end
p long("a" * 1000, [])

# a method whose value is its own scan
def own_scan(acc) = (t = +"ab"; [t, 1].first.scan(/./) { |m| m << "!"; acc << m })
acc6 = []
p own_scan(acc6), acc6

def own_scan_grown(acc)
  t = +"ab"
  t.scan(/./) { |m| m << "!"; acc << m; t << "z" if acc.size == 1 }
rescue RuntimeError => e
  p e.message
  t
end
acc7 = []
p own_scan_grown(acc7), acc7
