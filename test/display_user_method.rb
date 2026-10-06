# A class's own `display` answers ahead of Kernel#display, defined with
# def as well as by attr_reader; every other receiver keeps Kernel#display.

class Chip
  def display = [9, 8, 7]
  def via_self = self.display
  def bare = display
end
chip = Chip.new
p chip.display[1, 2]
p chip.via_self.size
p chip.bare.first

class Sub < Chip; end
p Sub.new.display.last

module Screen
  def display = "screen"
end
class Tv
  include Screen
end
p Tv.new.display

class Plain
  def to_s = "plain"
end
r = Plain.new.display
puts
p r

[Chip.new, Plain.new, 5].each do |o|
  v = o.display
  puts
  p v
end

P = Struct.new(:x) do
  def display = x * 2
end
p P.new(4).display

class Reader
  attr_reader :display
  def initialize = @display = :ok
end
p Reader.new.display

class Priv
  def show = display
  private
  def display = "private"
end
p Priv.new.show

class Args
  def display(n) = n + 1
end
p Args.new.display(4)

5.display
puts
"str".display
puts
