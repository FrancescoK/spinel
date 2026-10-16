# "#{obj}" for an object whose class has no to_s (its inspect does not count)
# renders Object#to_s, whatever the class's storage (the address varies run
# to run, so it is blanked here)

class N
  def initialize(x) = @x = x
  def inspect = "N"
end

class Q
  def initialize(x) = @x = x
end

puts "#{N.new(3)}".sub(/0x\h+/, "0x")
puts "[#{Q.new(4)}]".sub(/0x\h+/, "0x")
