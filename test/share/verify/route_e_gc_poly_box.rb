s = +"s"
t = s
box = [s, 1, :sym, 2.0, nil]
h = {a: s, b: 1}
30.times do |i|
  box[0] << "x"
  h[:a] << "y"
  junk = box.map { |e| e.to_s * 3 }
  box.rotate!
  box.rotate!(-1)
end
p s.size, t.equal?(box[0]), h[:a].equal?(s)
