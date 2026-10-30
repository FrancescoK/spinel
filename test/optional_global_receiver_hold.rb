# recv_read_before_args shape with $n nil when held
$n = 5
def gn
  1
end
p($n + [gn].first)
$n = nil
begin
  p($n + [gn].first)
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
rescue TypeError => e
  puts "TypeError: #{e.message}"
end
