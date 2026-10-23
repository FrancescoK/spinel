# A local bound by a for loop holds another name's String, so its writes are not fresh literals.
t = +"abc"
for s in [t]; end
acc = []
begin
  s.scan(/./) { |m| acc << m; m << "!"; t << "z" if acc.size == 1 }
  p acc
rescue => e
  p [e.class, e.message]
end
p s
