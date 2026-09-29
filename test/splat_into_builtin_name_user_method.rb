# A splat into a builtin's method name that a user class also defines, with
# another arity: the builtin receiver still answers, and the user method
# gets the elements or raises ArgumentError
class A
  def include?(x, y) = [:Ainc, x, y]
end

def static_len(o)
  one = [4]
  o.include?(*one)
end

def runtime_len(o, *args)
  o.include?(*args)
end

p static_len([4])
p static_len([5])
p((static_len(A.new) rescue $!.class))
p runtime_len([4], 4)
p runtime_len([4], 5)
p runtime_len(A.new, 1, 2)
p((runtime_len(A.new, 1) rescue $!.class))
p((runtime_len(A.new, 1, 2, 3) rescue $!.class))
a = A.new
two = [7, 8]
p a.include?(*two)
