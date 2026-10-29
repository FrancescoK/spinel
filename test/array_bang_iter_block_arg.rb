# The in-place Array iterators given a callable as `&blk`: the call was
# refused ("no route of the compiler took"), where map and select take it.
# Rack's QueryParser does `p.split('=', 2).map!(&unescaper)`.

up = ->(s) { s.upcase }
def unesc(s, u) = s.split("=", 2).map!(&u)
p unesc("a=b", up), unesc("c", up)

a = %w[b a c]
p a.collect!(&up), a

nums = [1, 2, 3, 4]
odd = ->(x) { x.odd? }
p nums.dup.select!(&odd), nums.dup.filter!(&odd), nums.dup.reject!(&odd)
p nums.dup.keep_if(&odd), nums.dup.delete_if(&odd)
p nums.dup.select!(&->(x) { x > 0 })    # nothing removed: nil
p nums.dup.sort_by!(&->(x) { -x })

# a Method object and a block parameter forwarded on
def twice(x) = x * 2
p [1, 2].map!(&method(:twice))
def each_up(arr, &blk) = arr.map!(&blk)
p each_up(%w[x y]) { |s| s * 2 }

# a literal block too: the element widening reads these rows now, so an
# inner Array a block appends a String to holds it (it raised TypeError)
outer = [[1], [2]]
p outer.reject! { |inner| inner << "s"; false }, outer
rows = [[1], [2]]
rows.map! { |r| r << "t" }
p rows
