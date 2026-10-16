begin
  FLAGS = 1 | 2 | (raise "constant operand")
rescue => e
  puts e.message
end

begin
  p 1 | (raise "or operand")
rescue => e
  puts e.message
end

begin
  p 1 & (raise "and operand")
rescue => e
  puts e.message
end

begin
  p 1 ^ (raise "xor operand")
rescue => e
  puts e.message
end

def no_value
  raise "method operand"
end

begin
  p 1 | no_value
rescue => e
  puts e.message
end
