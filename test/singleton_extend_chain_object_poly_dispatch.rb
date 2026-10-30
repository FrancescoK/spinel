# Each `extend` of an object moves it up one link of a chain of singleton
# classes, and the constructor stamps it with the original class's id until
# the first `extend` runs. Between two `extend`s the object's exact class is
# the link below, a class no `new` names, and a boxed receiver or a boxed
# rendering of the object must still find the methods of that class: the
# links below the last are built as the last one is.
module M1
  def tag = "m1"
end

module M2
  def tag = "m2"
end

module M3
  def tag = "m3"
end

class Foo
  def initialize
    @a = 1
  end

  def to_s
    "Foo!"
  end

  def show
    puts "Foo#show #{@a}"
  end

  def peek
    x = [self, 1]
    puts x.inspect.gsub(/0x\h+/, "XX")
    puts "#{x[0]}"
    x.each { |o| o.show if o.respond_to?(:show) }
  end
end

class Bar < Foo
  def show
    puts "Bar#show"
  end
end

f = Foo.new
b = Bar.new
f.peek
f.extend(M1)
f.peek
f.extend(M2)
f.peek
f.extend(M3)
f.peek
puts f.tag
b.peek
