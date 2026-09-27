# A splat among the arguments of Array's variadic mutators spreads its
# elements, whether the array is a rest parameter, an anonymous `*`, a local
# or a range, in value and statement position alike.

class Bag
  def initialize
    @a = [1, 2, 3]
  end

  def add(*) = @a.push(*)
  def add2(*r) = @a.push(*r)

  def front(*r)
    @a.unshift(*r)
    @a
  end

  def mid(*r)
    @a.insert(1, *r)
    @a
  end
end

p Bag.new.add(4, 5)
p Bag.new.add2(4, 5)
p Bag.new.add
p Bag.new.front(8, 9)
p Bag.new.mid(8, 9)

def lp(*r)
  a = [1, 2]
  a.push(*r)
end
p lp(3, 4)
p lp

def anon(*)
  a = [1, 2]
  a.append(*)
end
p anon(3, 4)

def lu(*r) = [1, 2].unshift(*r)
p lu(3, 4)
def lpre(*r) = [1, 2].prepend(*r)
p lpre(3, 4)
def li(*r) = [1, 2].insert(1, *r)
p li(3, 4, 5)
p li
def lneg(*r) = [1, 2].insert(-2, *r)
p lneg(3, 4)
def lc(*r) = [[0]].concat(*r)
p lc([1], [2, 3])

def fl(*r)
  a = [1.5]
  a.push(*r)
  a.unshift(*r)
end
p fl(2.5, 3.5)

def st(*r)
  a = ["x"]
  a.push(*r)
  a.insert(1, *r)
end
p st("y", "z")

xs = [3, 4]
b = [1, 2]
p b.push(0, *xs, 9)
p b.unshift(*xs, 7)
p b.unshift(*(5..6))

def sins(*r) = (+"ab").insert(1, *r)
p sins("X")
def pins(o, *r) = o.insert(1, *r)
p pins([1, 2], 7, 8)
p pins(+"ab", "Y")

begin
  [1, 2].insert(-4, *xs)
rescue IndexError => e
  p e.message
end
