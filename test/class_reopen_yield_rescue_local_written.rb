# A local a block writes before a raise keeps the new value after the
# rescue, where the block is given to a yielding method a program adds to
# Class (spliced under that method's setjmp), as for a class's own method.
class Class
  def guard
    begin
      yield
    rescue => e
      puts "rescued #{e.message}"
    end
    nil
  end
end

class Foo
  def self.guard
    begin
      yield
    rescue => e
      puts "rescued #{e.message}"
    end
    nil
  end
end

x = 1
Integer.guard { x = 2; raise "boom" }
p x
s = "a"
String.guard { s = "b"; raise ArgumentError, "bad" }
p s
y = 1
Foo.guard { y = 3; raise "boom" }
p y

def run
  z = 1
  Integer.guard { z += 4; raise "in method" }
  z
end
p run
[1, 2].each do |i|
  w = i
  Integer.guard { w = i * 10; raise "each #{i}" }
  p w
end
