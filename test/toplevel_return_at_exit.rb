at_exit { puts "at_exit 1" }
at_exit { puts "at_exit 2" }
def side = puts("side")
[1, 2, 3].each do |x|
  begin
    return side if x == 2
    puts x
  rescue => e
    puts "rescued #{e}"
  end
end
puts "unreachable"
