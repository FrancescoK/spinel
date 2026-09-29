# An ivar the program fills only by memoization (`def c = (@c ||= {})`) is
# nil until the memoizing reader first runs, so a call through the ivar
# itself before then is a call on nil and raises NoMethodError. It crashed
# with SIGSEGV.

class C
  def c = (@c ||= {})
  def a = (@a ||= [])
  def put_g(k, v) = c[k] = v
  def put_d(k, v) = @c[k] = v
  def put_s(k, v)
    @c[k] = v
    nil
  end
  def get_d(k) = @c[k]
  def a_push(v) = @a << v
  def a_size = @a.size
  def each_k
    @c.each { |k, _| p k }
    nil
  end
end

def t
  yield
rescue NoMethodError => e
  puts e.message
end

o = C.new
t { o.put_d("x", "y") }
t { o.put_s("x", "y") }
t { p o.get_d("x") }
t { o.a_push(1) }
t { p o.a_size }
t { o.each_k }
o.put_g(1, 2)
o.a << 3
o.put_d("x", "y")
p o.c, o.c[1] + 1, o.c["x"], o.get_d("x")
o.a_push(4)
p o.a, o.a_size
o.each_k
