begin
  (1..).to_set
rescue RangeError => e
  puts e.message
end

begin
  (1...).to_set
rescue RangeError => e
  puts e.message
end

r = (3..)
begin
  r.to_set
rescue RangeError => e
  puts e.message
end

begin
  ("a"..).to_set
rescue RangeError => e
  puts e.message
end

begin
  (1..).to_a
rescue RangeError => e
  puts e.message
end

begin
  (..0).to_set
rescue TypeError => e
  puts e.message
end

p (1..4).to_set
p (1...4).to_set
p (1..3).to_set { |x| x * x }
p ("a".."c").to_set
