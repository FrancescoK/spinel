begin
  p [1, 2].min_by("x") { |value| value }
rescue => error
  p [error.class, error.message]
end

begin
  p [1, 2].max_by("x") { |value| value }
rescue => error
  p [error.class, error.message]
end

# Validate before entering the block.
begin
  [1, 2].min_by("x") { |value| puts "unexpected block"; value }
rescue TypeError => error
  p error.message
end
begin
  [1, 2].max_by("x") { |value| puts "unexpected block"; value }
rescue TypeError => error
  p error.message
end
p [3, 1, 2].min_by(2.9) { |value| value }
p [3, 1, 2].max_by(2.9) { |value| value }
class Count
  def to_int
    puts "to_int"
    GC.start
    2
  end
end
p [3, 1, 2].min_by(Count.new) { |value| value }
p [3, 1, 2].max_by(Count.new) { |value| value }
begin
  p [1, 2].min_by(-1) { |value| value }
rescue ArgumentError => error
  p error.message
end
begin
  p [1, 2].max_by(-1) { |value| value }
rescue ArgumentError => error
  p error.message
end
