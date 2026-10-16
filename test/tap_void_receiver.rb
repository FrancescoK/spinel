# tap, then and yield_self on a receiver with no value of its own: a method
# whose last statement answers nothing usable, or one that always raises.
# The block gets nil (or never runs) and its parameter still compiles.

def quiet; puts "quiet"; end
def empty; end
def boom = raise(ArgumentError, "boom")

quiet.tap { |m| p m }
empty.tap { |m| p m }
p(empty.then { |m| m.nil? })
p(quiet.yield_self { |m| m.inspect })

def tapped = boom.tap { |m| m.foo }
def thened = boom.then { |m| m.foo }

class Base
  def build(x) = raise(NotImplementedError, "build #{x}")
end

class Child < Base
  def build(x)
    super.tap { |mod| mod.bar }
  end
end

begin; tapped; rescue ArgumentError => e; puts "tap: #{e.message}"; end
begin; thened; rescue ArgumentError => e; puts "then: #{e.message}"; end
begin; Child.new.build(1); rescue NotImplementedError => e; puts "super: #{e.message}"; end
p 1.tap { |n| n + 1 }
p 2.then { |n| n + 1 }
