# gets also sets $_, so a local from a call has a second name.
s = $stdin.gets
acc = []
begin
  s.scan(/./) { |m| acc << m; m << "!"; $_ << "z" if acc.size == 1 }
  p acc
rescue => e
  p [e.class, e.message]
end
p s
