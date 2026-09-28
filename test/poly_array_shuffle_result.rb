# Array#shuffle on a boxed receiver answers a new array that can be used
# as one; a Hash or String has no shuffle.
def shuf(o) = o.shuffle.size
p shuf([3, 1, 2])
p shuf([1, "a"])

def sorted(o) = o.shuffle.sort
p sorted([3, 1, 2])
p sorted([2, 1])

a = [[1, 2, 3], "s"]
r = a[0].shuffle
p r.sort, a[0]
[{ a: 1 }, "str"].each do |o|
  begin
    o.shuffle
  rescue NoMethodError => e
    p e.class
  end
end
