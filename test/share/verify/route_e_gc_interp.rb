s = +"s"
t = s
acc = []
50.times do |i|
  t << i.to_s
  acc << "#{s}-#{t}-#{i}"
  acc << format("%s|%s", s, t)
end
p acc.last, acc.size, s.size
