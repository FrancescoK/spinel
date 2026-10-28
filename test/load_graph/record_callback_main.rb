# A class body's call of a method that defines nothing itself still runs
# a method of the program's the runtime calls back: here the
# interpolation's to_s, which writes a global. The call stays opaque.
class Tag
  def to_s
    $shown = true
    "tag"
  end
end
class Foo
  def self.show(x) = "#{x}"
  show(Tag.new)
end
p $shown
p Foo.show(1)
