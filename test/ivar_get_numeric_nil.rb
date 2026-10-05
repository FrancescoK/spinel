# Reflection keeps a numeric slot's nil sentinel as nil, including through
# conversions, comparisons, local copies and a receiver held beside another type.
class IntegerSlot; end
o = IntegerSlot.new
o.instance_variable_set(:@x, 1)
p o.instance_variable_get(:@x)
o.instance_variable_set(:@x, nil)
p String(o.instance_variable_get(:@x))
p o.instance_variable_get(:@x).to_s
p((o.instance_variable_get(:@x) > 0 rescue $!.class))
p o.instance_variable_get(:@x).nil?
p o.instance_variable_get("@x").class
v = o.instance_variable_get(:@x)
p v, String(v), v.to_s, v.class
p((v > 0 rescue $!.class))
p [o.instance_variable_get(:@x), v]
o.instance_variable_set(:@x, 2)
p o.instance_variable_get(:@x), String(o.instance_variable_get(:@x))
p o.instance_variable_get(:@x) > 0

class FloatSlot; end
f = FloatSlot.new
f.instance_variable_set(:@y, 1.5)
p f.instance_variable_get(:@y)
f.instance_variable_set(:@y, nil)
p String(f.instance_variable_get(:@y))
p f.instance_variable_get(:@y).to_s
p((f.instance_variable_get(:@y) > 0 rescue $!.class))
p f.instance_variable_get(:@y).nil?
p f.instance_variable_get("@y").class
w = f.instance_variable_get(:@y)
p w, String(w), w.to_s, w.class
p((w > 0 rescue $!.class))
p [f.instance_variable_get(:@y), w]
f.instance_variable_set(:@y, 2.5)
p f.instance_variable_get(:@y), String(f.instance_variable_get(:@y))
p f.instance_variable_get(:@y) > 0

# A real NaN remains a Float, distinct from the private nil sentinel.
f.instance_variable_set(:@y, Float::NAN)
p f.instance_variable_get(:@y).nil?
p f.instance_variable_get(:@y).nan?

o.instance_variable_set(:@x, nil)
f.instance_variable_set(:@y, nil)
po = [o, 0][0]
pf = [f, 0][0]
p String(po.instance_variable_get(:@x))
p((po.instance_variable_get(:@x) > 0 rescue $!.class))
p String(pf.instance_variable_get("@y"))
p((pf.instance_variable_get("@y") > 0 rescue $!.class))
p [o, 0].map { |obj| obj.instance_variable_get(:@x) }
p [f, 0].map { |obj| obj.instance_variable_get(:@y) }
p IntegerSlot.new.instance_variable_get(:@x).nil?
p FloatSlot.new.instance_variable_get(:@y).nil?

# The same read in a method propagates its nilable result to its callers.
class Initialized
  def initialize
    @n = 1
  end
  def read
    instance_variable_get(:@n)
  end
end
z = Initialized.new
z.instance_variable_set(:@n, nil)
p String(z.read), z.read.class
p((z.read > 0 rescue $!.class))
