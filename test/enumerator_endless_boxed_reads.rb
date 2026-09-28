# An endless generator, boxed or stored, answers the reads that stop early:
# include?, first(n), take(n), take_while and find_index run it only as far
# as they need, where they materialized it and never returned (or answered
# false without looking).
inf = Enumerator.new { |y| i = 0; loop { y << (i += 1) } }
box = [inf, [1, 2, 3, 4]]
e = box[0]
p e.include?(3)
p e.member?(4)
p e.first(2)
p e.take(3)
p e.first
p e.take_while { |x| x < 4 }
p e.find_index { |x| x == 5 }
p e.find_index(6)
p e.find { |x| x > 3 }
p box[1].first(2)
p box[1].include?(3)

p inf.include?(3)
p inf.first(2)
p inf.take(3)
p inf.take_while { |x| x < 4 }
p inf.find_index { |x| x == 5 }
p inf.find_index(6)
p inf.lazy.map { |x| x * 2 }.first(3)
p inf.next

fin = Enumerator.new { |y| y << 1; y << 2; y << 3 }
p [fin, 0][0].find_index(2)
p [fin, 0][0].find_index(7)
p fin.find_index(3)
p fin.find_index(7)
p e.include?(300_000)
p inf.find_index(300_000)
