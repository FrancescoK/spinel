# An Integer-keyed Hash looked up by #fetch or #dig with a key that may be
# nil (or, boxed, of another class) misses as CRuby's lookup does: fetch
# raises KeyError naming the key, dig answers nil. The key was converted
# to an Integer first, and nil raised TypeError ("no implicit conversion
# from nil to integer"; under promote, "cannot store NilClass as a key").

def ni(x) = x > 0 ? x : nil

h = {1 => 10, 2 => 20}
s = {1 => "one"}

p h.fetch(ni(2)), s.fetch(ni(1))
p h.dig(ni(-1)), h.dig(ni(1)), s.dig(ni(-1)), s.dig(ni(1))
p h.fetch(ni(-1), :d), s.fetch(ni(-1), "z")

begin
  h.fetch(ni(-1))
rescue KeyError => e
  p [e.message, e.key, e.receiver]
end
begin
  s.fetch(ni(-2))
rescue KeyError => e
  p [e.message, e.key]
end

# a boxed key of another class misses the same way
[2, "a", nil].each do |k|
  begin
    p h.fetch(k)
  rescue KeyError => e
    p e.message
  end
end
