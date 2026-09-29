# A receiverless core-method call in a method added to a builtin class is a
# call on self.
class Array
  def my_sum
    total = 0
    each { |v| total += v }
    [total, length, first]
  end
  def my_last = self.last
end
class String
  def shout = upcase + "!"
end
class Integer
  def twice = self * 2 + abs
end
p [1, 2, 3].my_sum
p [4, 5].my_last
p "hi".shout
p 5.twice
