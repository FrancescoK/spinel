# A program that reopens Array has a class of its own named Array, which
# would be taken for the superclass of `class Stack < Array`: the subclass is
# refused rather than built as a subclass of the reopening (#7449).
class Array
  def second = self[1]
end

class Stack < Array
  def peek = last
end

s = Stack.new
s.push(1)
p s.peek, [1, 2].second
