# Splatted dig keys have a runtime depth, even on a homogeneous Array.
# spinel: gc-stress
keys = [1]
a = [1, 2, 3]
p a.dig(*keys)
p a.dig(*[0])
p a.dig(*[8])
f = [1.5, 2.5]
p f.dig(*keys)
p f.dig(*[0])
s = ["x", "y"]
p s.dig(*keys)
p s.dig(*[0])
nested = [[1, 2], [3, 4]]
p nested.dig(*keys)
p nested.dig(*[1, 0])
path = [0, 1, 0]
p [[1, [2, 3]]].dig(*path)
p [[1, [2, 3]]].dig(*[0, 1, 0])
p nested.dig(1, *[0])
p nested.dig(*[1], 0)
p nested.dig(*[1], *[0])
p nested.dig(*[8, 0])
p [{x: [7, 8]}].dig(*[0, :x, 1])
def dig_rest(*ks) = [[1, 2], [3, 4]].dig(*ks)
p dig_rest(1)
p dig_rest(1, 0)
p dig_rest(8, 0)
begin
  a.dig(*[])
rescue ArgumentError => e
  puts "#{e.class}: #{e.message}"
end
empty = []
begin
  nested.dig(*empty, *empty)
rescue ArgumentError => e
  puts "#{e.class}: #{e.message}"
end
begin
  dig_rest
rescue ArgumentError => e
  puts "#{e.class}: #{e.message}"
end
begin
  bad_path = [0, 0]
  a.dig(*bad_path)
rescue TypeError => e
  puts "#{e.class}: #{e.message}"
end
begin
  dig_rest(0, 0, 0)
rescue TypeError => e
  puts "#{e.class}: #{e.message}"
end
