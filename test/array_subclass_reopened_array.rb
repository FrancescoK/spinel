# An Array subclass beside a reopen of Array (#7449): the reopen is the
# chain's parent, the subclass's root the class right below it, and the
# reopen's methods are Array's -- on an instance of the subclass, from its
# own methods, and on a plain Array.
class Array
  def second = self[1]
  def sum_twice = sum * 2
end

class Stack < Array
  def peek = last
  def under = second
  def push(x)
    super(x * 10)
  end
end

s = Stack.new
s.push(1)
s.push(2)
p s.peek, s.under, s.second, s.sum_twice, s, s.class
p [1, 2].second, s.is_a?(Array), s.map { |x| x + 1 }.class
