class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class H
  def initialize = @arr = [3, 1]
  def run
    x = 5
    p @arr.each_with_object([]) { |e, m| m << x + e }
  end
end
H.new.run
