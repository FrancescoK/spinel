# send_rubyfunc_block benchmark (from yjit-bench)

class C
  def ruby_func(x)
    (x ^ 1) + 1
  end
end

obj = C.new
total = 0
i = 0
n = (ARGV[0] || 5000000).to_i
while i < n
  total = obj.ruby_func(total + i)
  total = obj.ruby_func(total + i)
  total = obj.ruby_func(total + i)
  total = obj.ruby_func(total + i)
  total = obj.ruby_func(total + i)
  total = obj.ruby_func(total + i)
  total = obj.ruby_func(total + i)
  total = obj.ruby_func(total + i)
  total = obj.ruby_func(total + i)
  i = i + 1
end
puts total
puts "done"
