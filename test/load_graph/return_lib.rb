puts "lib body"
BEGIN { puts "lib BEGIN" }
begin
  puts "in lib"
  return if true
ensure
  puts "lib ensure"
end
puts "not reached"
