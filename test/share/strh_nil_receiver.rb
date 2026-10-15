# spinel: share
# spinel: gc-minor
# A method's value, a parameter or an instance variable that is nil where an
# Array of shared Strings is expected: an operation on it raises CRuby's
# NoMethodError, and a safe navigation skips it.
def mk(f)
  t = +"t"
  a = [t]
  t << "!"
  f ? a : nil
end
x0 = +"x"
r = mk(true)
r << x0
n = mk(false)
p r, n
begin
  n << x0
rescue NoMethodError
  puts "nme push"
end
begin
  n.size
rescue NoMethodError
  puts "nme size"
end
begin
  n.each { |e| e << "." }
rescue NoMethodError
  puts "nme each"
end
begin
  n[0]
rescue NoMethodError
  puts "nme index"
end
p n&.size, r&.size
def take(a, s)
  a << s
  a.size
end
t = +"t"
rows = [t]
p take(rows, t)
begin
  take(nil, t)
rescue NoMethodError
  puts "nme take"
end
class L
  def add(s) = @rows << s
  def init = @rows = []
  def rows = @rows
  def bang = @rows.each { |x| x << "!" }
end
l = L.new
u = +"u"
begin
  l.add(u)
rescue NoMethodError
  puts "nme add"
end
begin
  l.bang
rescue NoMethodError
  puts "nme bang"
end
p l.rows
l.init
l.add(u)
l.bang
p l.rows, u

# the operations nil answers itself, on a nil and on an Array
m = mk(false)
q = mk(true)
p m.to_s, q.to_s
p m.inspect, q.inspect
p m.dup, q.dup
p m.to_a, q.to_a
puts "<#{m}>", "<#{q}>"
p m, q
p "#{m}|#{q}"
