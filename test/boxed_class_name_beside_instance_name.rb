# A boxed class's #name when a user class defines an instance #name: the class
# value must answer its own name, not raise and not enter the instance arm
class Shelf
  def name = "inst"
end

class Pen; end

class Holder
  def initialize(m) = @m = m
  def label = @m.name
end

def pick(i) = i == 0 ? Shelf : (i == 1 ? Pen : nil)

x = Shelf.new
[0, 1].each { |i| puts pick(i).name }
puts x.name
[x, Shelf, Pen].each { |o| puts o.name }
puts Holder.new(pick(0)).label
puts Holder.new(pick(1)).label
