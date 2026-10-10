# structaset benchmark (from yjit-bench)
TheClass = Struct.new(:v0, :v1, :v2, :levar)

def set_value_loop(obj, n)
  i = 0
  while i < n
    obj.levar = (obj.levar ^ i) + 1
    obj.levar = (obj.levar ^ i) + 1
    obj.levar = (obj.levar ^ i) + 1
    obj.levar = (obj.levar ^ i) + 1
    obj.levar = (obj.levar ^ i) + 1
    obj.levar = (obj.levar ^ i) + 1
    obj.levar = (obj.levar ^ i) + 1
    obj.levar = (obj.levar ^ i) + 1
    obj.levar = (obj.levar ^ i) + 1
    obj.levar = (obj.levar ^ i) + 1
    i = i + 1
  end
  obj.levar
end

obj = TheClass.new(1, 2, 3, 1)
puts set_value_loop(obj, (ARGV[0] || 1000000).to_i)
puts "done"
