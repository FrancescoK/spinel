acc = []
src = [+"a", +"b", +"c"]
keep = src[0]
30.times do |i|
  src.each { |w| w << i.to_s; acc << w }
  src.each_with_index { |w, j| w << "-" if j == 1 }
  junk = (1..20).map { |j| "j#{j}" }
  src.map! { |w| w }
end
p keep.size, acc.size, acc[0].equal?(keep), acc.uniq.size, src[1][-5, 5]
