# A Class value that only `superclass` answers (the program calls no `.class`)
# and a poly slot holds is kept off the arm of the class it stands for: the
# dispatch of `val` sends it to NoMethodError, as CRuby does, where it entered
# K's instance arm and read an object out of K's class index (a segfault).
class Filler; end

class K
  def initialize(v = 2) = @v = v
  def val = @v
end

class K2 < K; end

xs = [K.new(1), K2.superclass, K2.new]
xs.each do |o|
  begin
    puts o.val
  rescue NoMethodError => e
    puts "NoMethodError: #{e.message}"
  end
end
