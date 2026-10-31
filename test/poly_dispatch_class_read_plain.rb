# A `.class` read that only builds a string, compares, asks a name or is the
# subject of a `case` does not make a program's classes Class values, so the
# poly dispatches on `val` need no guard against one. The same program holds
# a Struct class and a Data class as values in the slots, where it does.
class Filler; end

class A
  def initialize(v) = @v = v
  def val = @v
end

class B
  def initialize(v) = @v = v
  def val = @v * 2
end

Pt = Struct.new(:val)
Dt = Data.define(:val)

xs = [A.new(1), B.new(2), Pt.new(3), Dt.new(val: 4)]
total = 0
xs.each { |o| total += o.val }
puts total

xs.each do |o|
  label = "#{o.class}"
  same = o.class == A
  name = o.class.name
  kind = case o.class
         when A then "a"
         when B then "b"
         else "other"
         end
  tern = "#{o.val > 2 ? o.val : o.class}"
  puts [label, same, name, kind, tern].inspect
end

slots = [A.new(5), Pt, Pt.new(6), Dt, B]
slots.each do |s|
  begin
    puts s.val
  rescue NoMethodError => e
    puts "NoMethodError: #{e.message}"
  end
end
