class Array
  def each_with_object(m) = (each { |x| yield(x, m) }; m)
end
class H
  def initialize = @arr = [3, 1]
  def run
    p @arr.each_with_object([]) { |e, m| m << e }
  end
end
H.new.run
