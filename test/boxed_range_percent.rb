# % on a Range read out of a mixed Array steps through it like a plain
# Range (Range#% is #step); a boxed Integer or Float keeps its modulo.
def t
  p yield
rescue => e
  puts "#{e.class}: #{e.message}"
end
x = [(1..10), 5][0]
t { (x % 3).to_a }
t { (x % 2.5).to_a }
t { ([(1...10), 5][0] % 3).to_a }
t { ([(1.0..2.0), 5][0] % 0.5).to_a }
t { ([(1.0...2.0), 5][0] % 0.5).to_a }
t { (x % 3).map { |v| v * 2 } }
t { (x % 0).to_a }
t { (x % -1).to_a }
t { [7, :a][0] % 3 }
t { [7.5, :a][0] % 2 }
t { (x % "a").to_a }
t { (x % nil).to_a }
