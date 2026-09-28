# Module#< / <= / > / >= / <=> on a class value read out of an Array or Hash:
# tri-state against a class, TypeError against a non-class.

class Base
  def initialize(path, read_only: false)
    @path = path
    @read_only = read_only
  end

  def read_only? = @read_only
end

class Sub < Base
  include Comparable
end

class Other
  def initialize(path)
    @path = path
  end
end

k = [Sub][0]
b = [Base][0]
o = {x: Other}[:x]
p k < Base
p k <= Base
p k > Base
p k >= Base
p k <=> Base
p Base <=> k
p k < b
p b > k
p b <= k
p k <=> b
p k < k
p k <= k
p k <=> k
p k >= k
p k < Other
p k <=> o
p k < Comparable
p k <= Comparable
p Base > k
p Base < k
p Sub < b
p Sub <=> b
begin
  k < 3
rescue TypeError => e
  p e.message
end
begin
  k <= "x"
rescue TypeError => e
  p e.message
end
p k <=> 3

TYPES = { ".a" => Sub, ".b" => Other }.freeze

def open_it(ext)
  storage = TYPES[ext]
  storage < Base ? storage.new("x", read_only: true) : storage.new("x")
end

p open_it(".a").class
p open_it(".b").class
p open_it(".a").read_only?

def sub_of?(k, base) = k <= base
p sub_of?(Sub, Base)
p sub_of?(Base, Sub)

class Holder
  def initialize(k) = @k = k
  def below?(x) = @k < x
end
p Holder.new(TYPES[".a"]).below?(Base)

$g = [Sub, Base]
p $g[0] < $g[1]
p $g[1] > $g[0]
p $g.sort
p [Base, Sub].min
p TYPES[".a"] < Base ? :sub : :not
x = (TYPES[".b"] < Base)
p x
p x.nil?
begin
  TYPES[".x"] < Base
rescue NoMethodError => e
  p e.class
end
begin
  Base < TYPES[".a"].name
rescue TypeError => e
  p e.message
end
p Base <=> TYPES[".a"].name
p [Integer][0] < Comparable
p [Integer][0] <= Numeric
p Numeric > [Integer][0]
p [String][0] < Numeric
