# A method a required file defines and the program defines again, at the
# top level and in a class reopened in another file: each call reaches the
# definition in effect where it runs, in the required file, in a class
# body and after the later def. Both were refused under graph.
require_relative "versions_across_lib"
puts greet
def greet = "hi"
puts greet
class Counter
  p new.step
  def step = 2
  p new.step
end
p Counter.new.step
