# K.extend(M) as a statement, in K's own body or at the top level, is
# the `extend M` of that body (console's `Console.extend(Interface)`)
module Speak
  def hello = "hello from #{name}"
end
module Loud
  def shout = "HEY"
end
module Console
  Console.extend(Speak)
end
Console.extend(Loud)
p Console.hello
p Console.shout
p Console.is_a?(Speak), Console.is_a?(Loud)
