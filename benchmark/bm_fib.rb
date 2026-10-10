def fib(n)
  if n < 2
    n
  else
    fib(n - 1) + fib(n - 2)
  end
end

n = (ARGV[0] || 34).to_i
puts fib(n)
