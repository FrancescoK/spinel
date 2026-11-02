class Array
  def each_with_object(m) = (puts "mine"; yield(first, m); m)
  def each = (puts "mine-each"; i = 0; while i < size; yield self[i]; i += 1; end; self)
  def map = (puts "mine-map"; r = []; i = 0; while i < size; r << yield(self[i]); i += 1; end; r)
  def each_with_index = (puts "mine-ewi"; i = 0; while i < size; yield self[i], i; i += 1; end; self)
  def select = (puts "mine-sel"; r = []; each { |x| r << x if yield(x) }; r)
end
class H
  def initialize = @arr = [3, 1]
  def run
    p @arr.each_with_object([]) { |e, m| m << e }
    p @arr.each { |e| e }
    p @arr.map { |e| e + 1 }
    p @arr.each_with_index { |e, i| e }
    p @arr.select { |e| e > 1 }
  end
end
H.new.run
