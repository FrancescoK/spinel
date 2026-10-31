# A Class value that `send(:class)`, `public_send(:class)` or `__send__(:class)`
# answers, and a poly slot holds, is kept off the arm of the class it stands
# for: the dispatch of `tag` sends it to NoMethodError, as CRuby does, where it
# entered the class's instance arm and read an object out of its class index
# (a segfault). The program calls no `.class` itself.
class Filler; end

class A
  def initialize(v = 1) = @v = v
  def tag = "A#{@v}"
end

class B
  def initialize(v = 2) = @v = v
  def tag = "B#{@v}"
end

def show_all(xs)
  xs.each do |o|
    begin
      puts o.tag
    rescue NoMethodError => e
      puts "NoMethodError: #{e.message}"
    end
  end
end

show_all([A.new(3), B.new(4), B.new.send(:class)])
show_all([A.new(5), A.new.public_send(:class), B.new(6)])
show_all([B.new(7), A.new.__send__("class"), A.new(8)])
