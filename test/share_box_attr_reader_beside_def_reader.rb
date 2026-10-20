# A box whose classes answer a reader of one name, an attr_accessor in one
# and a def in another: the String read through the box is the one the
# field holds, which an append through it changes. The attr reader's field
# was left out of the call's value, and its String came back as a copy
# (#9814).

class Widget
  attr_accessor :name
end

class Gadget
  def name
    @name
  end

  def name=(v)
    @name = v
  end
end

class Plate
  attr_reader :name

  def initialize(n) = @name = n
end

Point = Struct.new(:name)

def shout(s)
  s << "!"
end

w = Widget.new
w.name = +"w"
g = Gadget.new
g.name = +"g"
pl = Plate.new(+"p")
pt = Point.new(+"s")
[w, g, pl, pt].each { |x| shout(x.name) }
p w.name, g.name, pl.name, pt.name

names = [w, g].map(&:name)
names.each { |s| s << "?" }
p w.name, g.name

quiet = Widget.new
quiet.name = "frozen"
p [quiet, g].map { |x| x.name.length }
