# yjit-bench: object-new - object allocation performance
# Ported from https://github.com/Shopify/yjit-bench

class SimpleObj
  def initialize(x)
    @x = x
  end

  def x
    @x
  end
end

sum = 0
i = 0
n = (ARGV[0] || 1000000).to_i
while i < n
  obj = SimpleObj.new(i)
  sum = (sum ^ obj.x) + 1
  i = i + 1
end
puts sum
