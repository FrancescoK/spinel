# setivar_young benchmark (from yjit-bench)

class TheClass
  def initialize
    @v0 = 1
    @v1 = 2
    @v3 = 3
    @levar = TheClass.new_inner
    @tag = "young"
  end

  def self.new_inner
    0
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

tc = TheClass.new
puts tc.set_value_loop((ARGV[0] || 1000000).to_i)
puts "done"
