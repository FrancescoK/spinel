# An element of a method's fixed tuple, read at a literal index into a
# variable, keeps its own type: a String read that way was a boxed value,
# and storing it into an Integer array raised TypeError.
class P
  def initialize(n) = @n = n
  def to_s = "P#{@n}"
end

def pair = [1, "x"]
def trip = [2.5, :s, true, P.new(3)]

x = pair[1]
b = [0, 0]
b[1] = x
p b

class K
  def two = ["a", 7]
  def self.cm = [:q, 1]

  def go
    @v = two[0]
    b = [0]
    b[0] = @v
    p b
    p two[-1] + 1
  end
end
K.new.go

$g = pair[1]
arr = [1]
arr << $g
p arr

f = trip[0]
p f * 2
s = trip[1]
p s.to_s
t = trip[2]
p(t ? "y" : "n")
o = trip[3]
puts o
p o.class

h = {"a" => 1}
k = pair[1]
h[k] = 5
p h
p K.cm[0]
p pair[1].upcase, "#{pair[1]}!"
p pair[5]
w = pair[-2]
p w + 1
