# A call on a local or a parameter holding an Array, a Hash or an object runs
# on the value Ruby read first: an argument that reassigns the variable
# (`x.join((x = nil; ","))`) does not change the receiver the call is tested
# and made on. A nil receiver raises NoMethodError after the arguments ran,
# whatever they assigned.
def arr(f)
  t = +"t"
  a = [t, "u"]
  t << "!"
  f ? a : nil
end

def hsh(f) = f ? { a: 1 } : nil

class Box
  def initialize = @v = 7

  def get(x) = @v + x
end

def box(f) = f ? Box.new : nil

def try_call
  yield
rescue NoMethodError
  puts "nme"
end

x = arr(true)
p x.join((x = nil; ","))
y = arr(true)
p y.include?((y = nil; "u"))
z = arr(false)
try_call { p z.join((z = arr(true); ",")) }

def join_param(a) = a.join((a = nil; ","))

p join_param(arr(true))
try_call { join_param(arr(false)) }

h = hsh(true)
p h.fetch((h = nil; :a))
g = hsh(false)
try_call { p g.fetch((g = hsh(true); :a)) }
p g

o = box(true)
p o.get((o = nil; 1))
q = box(false)
try_call { p q.get((q = box(true); 1)) }

# the write an argument made to the receiver's variable is kept when the call
# then raises, for an Array of Strings and a Hash
z2 = hsh(false)
begin
  z2.fetch((z2 = hsh(true); :a))
rescue NoMethodError
  puts "nme"
end
p z2
z3 = arr(false)
begin
  z3.join((z3 = arr(true); ","))
rescue NoMethodError
  puts "nme"
end
p z3
