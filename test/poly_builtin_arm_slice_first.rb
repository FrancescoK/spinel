# A user class that owns slice or first opens a dispatch on a boxed value.
# The other values still answer as their own class does: a String, a
# Symbol or an Array slices, a Hash slices by keys, and a value with no
# such method raises NoMethodError.
class Foo
  def slice(a); "foo#{a}"; end
  def first(*a); "foo-first"; end
end

class Walk
  include Enumerable
  def each; yield 7; yield 8; yield 9; end
end

class Plain; end

def pick(i)
  case i
  when 0 then "hello"
  when 1 then [1, 2, 3]
  when 2 then 42
  when 3 then :sym
  when 4 then {a: 1, b: 2}
  when 5 then nil
  when 6 then 1.5
  when 7 then Foo.new
  when 8 then (1..5)
  when 9 then Walk.new
  else Plain.new
  end
end

11.times do |i|
  x = pick(i)
  begin
    p x.slice(1)
  rescue NoMethodError => e
    puts "slice: NoMethodError #{e.name}"
  end
  begin
    p x.slice(0, 2)
  rescue NoMethodError, ArgumentError => e
    puts "slice2: #{e.class}"
  end
  begin
    p x.first(2)
  rescue NoMethodError => e
    puts "first: NoMethodError #{e.name}"
  end
end
