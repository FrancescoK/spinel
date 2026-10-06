# Boxed ordinary and Struct receivers evaluate the value before checking freeze.
class K; end
S = Struct.new(:a)
k = K.new
s = S.new(1)
[k, s, 0].each do |o|
  next if o == 0
  o.instance_variable_set(:@z, 1)
  o.freeze
  begin
    o.instance_variable_set(:@z, (puts "value"; 2))
    puts "stored"
  rescue FrozenError
    puts "frozen"
  end
  p o.instance_variable_get(:@z)
end
x = [K.new.freeze, 1][0]
begin
  x.instance_variable_set(:@new_slot, 5)
  puts "stored"
rescue FrozenError
  puts "frozen new slot"
end
