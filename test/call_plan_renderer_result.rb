# Exception renderer results keep their value and effects in boxed slots.
class E1 < StandardError
  def to_s
    puts "side"
  end
end
class E2 < StandardError
  def to_s = raise("boom")
end
class E3 < StandardError
  def to_s = [1, 2]
end
class E4 < StandardError
  def to_s = 1.5
end
class E5 < E4
  def message = "five"
end
p E1.new.message
m = E1.new.message
p m
begin
  E2.new.message
rescue => e
  p e.message
end
p E3.new.message
p E4.new.message
p E5.new.message
z = [E4.new, E5.new][ARGV.size].message
p z
