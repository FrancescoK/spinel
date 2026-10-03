# #step and #bsearch with a block on a Range read out of a slot that holds
# other kinds too: every Range kind (Integer, Float, String, endless)
# answers as its typed Range does, and an Integer, a Float or an Array in
# the same slot keeps its own step / bsearch. Both raised NoMethodError for
# any boxed Range.

def pick(k)
  case k
  when 0 then 1..10
  when 1 then 1.0..2.0
  when 2 then 1...10
  when 3 then "a".."e"
  when 4 then 1..
  when 5 then [1, 3, 5, 7, 9]
  when 6 then 7
  when 7 then 2.5
  when 8 then nil
  else "x"
  end
end

puts "-- step"
pick(0).step(3) { |x| p x }
pick(2).step(4) { |x| p x }
pick(1).step(0.5) { |x| p x }
pick(3).step(2) { |x| p x }
pick(4).step(5) { |x| p x; break if x > 10 }
pick(6).step(10, 2) { |x| p x }
pick(7).step(4.0, 0.5) { |x| p x }
p(pick(0).step(4) { |x| x })
p(pick(1).step(0.25) { |x| x })
p(pick(3).step(3) { |x| x })

puts "-- bsearch"
p pick(0).bsearch { |x| x >= 4 }
p pick(2).bsearch { |x| x >= 40 }
p pick(1).bsearch { |x| x >= 1.5 }
p pick(4).bsearch { |x| x >= 7 }
p pick(0).bsearch { |x| x <=> 6 }
p pick(5).bsearch { |x| x >= 4 }

puts "-- no such method"
[8, 9].each do |k|
  begin
    pick(k).step(2) { |x| p x }
  rescue NoMethodError => e
    puts e.message
  end
  begin
    pick(k).bsearch { |x| x }
  rescue NoMethodError => e
    puts e.message
  end
end
