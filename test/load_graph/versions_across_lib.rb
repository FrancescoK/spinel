# Required by versions_across_main.rb: the first definitions, and calls
# that run while they are in effect.
def greet = "hello"
class Counter
  def step = 1
end
puts greet
p Counter.new.step
