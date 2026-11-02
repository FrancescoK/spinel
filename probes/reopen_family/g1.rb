class Array
  def each
    puts "mine"; i = 0
    while i < size
      yield self[i]
      i += 1
    end
    self
  end
end
class H
  def initialize = @arr = [3, 1]
  def run
    x = 5
    @arr.each { |e| x += e }
    p x
  end
end
H.new.run
