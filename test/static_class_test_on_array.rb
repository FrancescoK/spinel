# A class test on a local that holds a typed Array is decided when the
# program is analyzed, whatever class it names: `K === v` and `v.is_a?(K)`
# alike. An Array is one of Array, Object, Enumerable and the modules the
# program mixed into them, and of no other class, so the arm for another
# class (a user class's, here Bag's, whose `adopt` takes the Array on as
# its storage) is dead and not compiled; it used to be compiled, and
# refused the call it makes.

class Bag
  def initialize
    @data = []
    @ident = false
  end

  def add(x)
    @data.push(x) unless @data.any? { |e| e == x }
    self
  end

  def remove(x)
    i = @data.rindex { |e| e == x }
    @data.delete_at(i) if i
    self
  end

  def adopt(members, ident)
    @data = members
    @ident = ident
  end
  private :adopt

  def keep_if
    r = []
    i = 0
    while i < @data.size
      x = @data[i]
      r.push(x) if yield(x)
      i += 1
    end
    adopt(r, @ident)
    self
  end

  def replace(enum)
    if Bag === enum
      adopt(enum.to_a, false)
      return self
    end
    @data = []
    enum.to_a.each { |x| add(x) }
    self
  end

  def replace_kind(enum)
    if enum.is_a?(Bag)
      adopt(enum.to_a, false)
      return self
    end
    @data = enum.dup
    self
  end

  def replace_unless(enum)
    unless Bag === enum
      @data = enum.dup
    else
      adopt(enum.to_a, false)
    end
    self
  end

  def to_a = @data
end

module Tagged; end
class Array
  include Tagged
end

class Other; end

b = Bag.new
b.add(1).add("s").add(:k)
b.keep_if { |x| x != 1 }
p b.to_a
b.replace([1, 2])
b.add(3)
p b.to_a
b.replace_kind([4, 5])
p b.to_a
b.replace_unless([6, 7])
p b.to_a
b.replace([9, 8])
p b.to_a

def tests(a)
  r = []
  r << (Array === a)
  r << (Object === a)
  r << (Enumerable === a)
  r << (Comparable === a)
  r << (Hash === a)
  r << (Bag === a)
  r << (Other === a)
  r << (Tagged === a)
  r << a.is_a?(Array)
  r << a.kind_of?(Enumerable)
  r << a.is_a?(Other)
  r << a.is_a?(Tagged)
  r << a.instance_of?(Array)
  r << a.instance_of?(Object)
  r << a.instance_of?(Bag)
  r
end

p tests([1, 2])
p tests([1, 2, 3])
p tests(["a", "b"])
p tests([1.5, 2.5])

# an elsif chain whose first tests are dead for an Array argument
def describe(x)
  if x.is_a?(Integer)
    "integer"
  elsif x === 1.5 || Float === x
    "float"
  elsif Bag === x
    "bag"
  elsif x.is_a?(Hash)
    "hash"
  elsif x.is_a?(Array)
    "array of #{x.size}"
  else
    "other"
  end
end
puts describe([1, 2])
puts describe([])

def describe_all(x)
  if Hash === x
    "hash"
  elsif Bag === x
    "bag"
  else
    "no Hash, no Bag"
  end
end
puts describe_all([3])

# an Array subclass's instance is an Array: `Array === s` stays a run-time test
class Stack < Array
end
s = Stack.new
s << 1
if Array === s
  puts "a Stack is an Array"
else
  puts "a Stack is no Array"
end
if Bag === s
  puts "a Stack is a Bag"
else
  puts "a Stack is no Bag"
end

ints = [1, 2, 3]
words = %w[x y]
puts(Bag === ints ? "bag" : "not a bag")
puts(Other === words ? "other" : "not other")
puts(Tagged === ints ? "tagged" : "not tagged")
puts(ints.is_a?(Bag) ? "bag" : "not a bag")
puts(ints.is_a?(Enumerable) ? "enumerable" : "not enumerable")
puts(ints.instance_of?(Array) ? "an Array" : "not an Array")
puts(ints.instance_of?(Enumerable) ? "an Enumerable" : "not an Enumerable")

# an Array local that may hold nil (a missing element) is no Array there: the
# tests nil answers differently from an Array stay run-time ones, and those
# it answers alike are still decided
def element(rows, i)
  a = rows[i]
  r = []
  r << (Array === a ? "array" : "not array")
  r << (Enumerable === a ? "enumerable" : "not enumerable")
  r << (NilClass === a ? "nil" : "not nil")
  r << (Object === a ? "object" : "not object")
  r << (Bag === a ? "bag" : "not bag")
  r << (Hash === a ? "hash" : "not hash")
  puts "not an array" unless Array === a
  r
end
rows = [[1], [2]]
p element(rows, 0)
p element(rows, 5)
