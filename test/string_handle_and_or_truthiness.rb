# `s && s.upcase || :none` with s a String held as its handle: the left's
# truthiness was read as always true, so a nil s ran upcase on nil.
s = "gadget"
h = { k: s && s.upcase || :none }
p h
t = ARGV.empty? ? nil : "gadget"
h2 = { k: t && t.upcase || :none }
p h2
def kind = "gadget"
def note(args) = p(args)
begin
  note(kind: kind && kind.vendor || :none)
rescue NoMethodError => e
  puts "#{e.class}: #{e.name}"
end
