# object-new-initialize benchmark (from yjit-bench)
class C
  attr_reader :a

  def initialize(a, b, c, d)
    @a = a
    @b = b
    @c = c
    @d = d
    @e = "c"
  end
end

def test(i)
  C.new(i, 2, 3, 4)
end

total = 0
i = 0
n = (ARGV[0] || 1000000).to_i
while i < n
  total = (total ^ test(i).a) + 1
  i = i + 1
end
puts total
puts "done"
