# A Struct or Data class that its own block hands out as `self` (a `def
# self.me`) is a Class value, as a class written with `class` is when its body
# does. A poly slot holding it is kept off the arm of the record's own `tag`:
# the dispatch sends it to NoMethodError, as CRuby does, where it entered the
# instance arm and read an object out of the class index (a segfault).
class Filler; end

class Q
  def initialize(v = 2) = @v = v
  def tag = "Q#{@v}"
end

def show_all(xs)
  xs.each do |o|
    begin
      puts o.tag
    rescue NoMethodError => e
      puts "NoMethodError: #{e.message}"
    end
  end
end

P = Struct.new(:v) do
  def tag = "P#{v}"
  def self.me = self
end

D = Data.define(:v) do
  def tag = "D#{v}"
  def self.me = self
end

show_all([P.new(1), Q.new(2), P.me])
show_all([D.new(v: 3), Q.new(4), D.me])
