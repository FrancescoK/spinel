def t
  "ok #{yield.inspect}"
rescue => e
  "#{e.class}: #{e.message}"
end

[nil, true, false, 7, 2.5, "s", :y].each do |v0|
  v = [v0, [1]][0]
  puts "#{v0.inspect}.to_s #{t { v.to_s(foo: 1) }}"
  puts "#{v0.inspect}.inspect #{t { v.inspect(foo: 1) }}"
end
[nil, 7, 2.5, "12"].each do |v0|
  v = [v0, [1]][0]
  puts "#{v0.inspect}.to_i #{t { v.to_i(foo: 1) }}"
  puts "#{v0.inspect}.to_f #{t { v.to_f(foo: 1) }}"
end
b = [7, "x"][0]
puts "base #{t { b.to_s(2) }} #{t { "ff".to_i(16) }}"
puts "nil.to_s #{t { nil.to_s(foo: 1) }}"
puts "pow #{t { 2.pow(foo: 1) }}"
puts "fdiv #{t { 2.5.fdiv(foo: 1) }}"
puts "div #{t { 2.div(foo: 1) }}"
puts "digits #{t { 2.digits(foo: 1) }}"
puts "floor #{t { 2.floor(foo: 1) }}"
puts "upto #{t { 2.upto(foo: 1) { } }}"
puts "round #{t { 2.5.round(half: :even) }}"
