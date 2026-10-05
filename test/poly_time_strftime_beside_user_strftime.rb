# Time#strftime keeps its arm in a poly dispatch beside a user class that
# defines strftime: with only the user arm, a real Time raised NoMethodError
# (#7334).
class Day
  def initialize(y) = @y = y
  def strftime(p) = "D#{@y}#{p}"
end

class Stamp
  def initialize(n) = @n = n
  def strftime(p) = "S#{@n}"
end

def fmt(t)
  t.strftime("%Y")
end

puts fmt(Time.at(0).utc)
puts fmt(Day.new(3))
puts fmt(Stamp.new(9))

vals = [Time.at(86400 * 365).utc, Day.new(1), Stamp.new(2)]
vals.each { |v| puts v.strftime("%Y-%m") }
p vals.map { |v| v.strftime("%m") }

def try(v)
  puts v.strftime("%Y")
rescue NoMethodError => e
  puts "NoMethodError: #{e.message}"
end
try(Time.at(0).utc)
try(Day.new(5))
try(nil)
try(12)
