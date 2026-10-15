# A parameter seeded `untyped` that its call sites hand a Class: `klass.new`
# constructs that class. The receiver's type was not known yet when the
# classes a run can construct were counted, so the class had no arm in the
# boxed `new` and raised NoMethodError (#9208).
class Gadget
  def ping(x)
    x.to_s
  end
end

class Gizmo
  def initialize(n = 2)
    @n = n
  end

  def ping(x)
    x.to_s * @n
  end
end

module Widget
  def self.run(name, klass)
    klass.new.ping(name)
  end
end

p Widget.run(:a, Gadget)
p Widget.run(:b, Gizmo)
