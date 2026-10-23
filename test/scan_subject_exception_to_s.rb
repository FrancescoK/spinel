# An exception's to_s is its message String, so a local from a call has a second name.
t = +"abc"; ex = RuntimeError.new(t); s = ex.to_s
acc = []
begin
  s.scan(/./) { |m| acc << m; m << "!"; t << "z" if acc.size == 1 }
  p acc
rescue => e
  p [e.class, e.message]
end
p s
