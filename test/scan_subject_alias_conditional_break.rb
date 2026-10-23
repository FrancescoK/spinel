# The two String representations refused this program; with one it answers as CRuby.
# A block that breaks only on some turns returns to the scan on the others, so a subject it changes keeps the refusal.
t = +"abc"
s = [t, 1].first
x = nil
begin
  x = s.scan(/./) { |m| t << "z"; m << "!"; break m if m == "b" }
rescue RuntimeError => e
  p e.message
end
p x, s
