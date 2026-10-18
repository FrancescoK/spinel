# A bare `new` in a class method is Class#new even when the class defines a
# yielding instance method named new (optparse's OptionParser#new pushes a
# List, and OptionParser.getopts calls `new.getopts`): the instance method
# was inlined into the class method with the class as self, and the C did
# not compile.
class P
  def initialize = (@stack = [])
  def new
    @stack.push(1)
    if block_given?
      yield self
    else
      self
    end
  end
  def size = @stack.size
  def go(x) = x + size
  def self.go(x) = new.go(x)
  def self.fresh = new { |q| q.size }
end
p P.go(3)
p P.new.new.size
p P.new.new { |q| q.size + 10 }
p P.fresh.class
