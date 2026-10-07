# A value read out of a mixed Array with no to_h, to_r or to_c raises the
# NoMethodError CRuby words ("for true", "for an instance of Array"), not
# one naming its class ("for TrueClass"); and a Range's to_h is
# Enumerable's, a TypeError over its non-pair elements, {} when empty.
xs = [true, false, :a, [1], {a: 1}, 1..2, "12", 2.5, nil, 3, ("a".."b"), (1...1)]
%i[to_h to_r to_c].each do |m|
  puts "-- #{m}"
  xs.each do |x|
    p x.public_send(m)
  rescue NoMethodError, TypeError, ArgumentError => e
    puts "#{e.class}: #{e.message}"
  end
end
puts "-- to_a / with / rationalize"
[true, :a, 2.5, [1], {a: 1}].each do |x|
  begin
    p x.to_a
  rescue NoMethodError => e
    puts e.message
  end
  begin
    p x.with
  rescue NoMethodError => e
    puts e.message
  end
  begin
    p x.rationalize
  rescue NoMethodError => e
    puts e.message
  end
end
