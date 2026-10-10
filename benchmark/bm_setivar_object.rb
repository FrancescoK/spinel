# setivar_object benchmark (from yjit-bench)

class TheClass
  def initialize
    @v0 = 1
    @v1 = 2
    @v3 = 3
    @levar = 1
    @tag = "obj"
  end

  def set_value_loop(val, n)
    i = 0
    while i < n
      @levar = (@levar ^ val) + i
      @levar = (@levar ^ val) + i
      @levar = (@levar ^ val) + i
      @levar = (@levar ^ val) + i
      @levar = (@levar ^ val) + i
      @levar = (@levar ^ val) + i
      @levar = (@levar ^ val) + i
      @levar = (@levar ^ val) + i
      @levar = (@levar ^ val) + i
      @levar = (@levar ^ val) + i
      i = i + 1
    end
    @levar
  end
end

tc = TheClass.new
puts tc.set_value_loop(999, (ARGV[0] || 1000000).to_i)
puts "done"
