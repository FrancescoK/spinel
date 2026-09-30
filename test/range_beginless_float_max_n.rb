begin
  p (..1.0).max(2)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

begin
  p (...1.5).max(1)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

begin
  p (nil..2.5).max(0)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

r = (..1.0)
begin
  p r.max(2)
rescue TypeError => e
  puts "TypeError: #{e.message}"
end

begin
  p (..1.0).max(-1)
rescue ArgumentError
  puts "ArgumentError"
end

p (..1).max(2)
p (...1).max(2)
p (1..2.5).max(2)
