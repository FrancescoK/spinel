# yjit-bench: setivar - instance variable write performance
# Ported from https://github.com/Shopify/yjit-bench

class TheClass
  def initialize
    @v0 = 1
    @v1 = 2
    @v3 = 3
    @levar = 1
  end

  def set_value_loop(n)
    i = 0
    while i < n
      @levar = (@levar ^ i) + 1
      @levar = (@levar ^ i) + 1
      @levar = (@levar ^ i) + 1
      @levar = (@levar ^ i) + 1
      @levar = (@levar ^ i) + 1
      @levar = (@levar ^ i) + 1
      @levar = (@levar ^ i) + 1
      @levar = (@levar ^ i) + 1
      @levar = (@levar ^ i) + 1
      @levar = (@levar ^ i) + 1
      i = i + 1
    end
    @levar
  end
end

obj = TheClass.new
result = obj.set_value_loop((ARGV[0] || 1000000).to_i)
puts result
