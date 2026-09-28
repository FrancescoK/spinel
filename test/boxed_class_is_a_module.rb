# A class read out of a container is a Module too (Class < Module), as a
# module read out of one is; neither is an Integer.
module Cmp; end
class Foo; end
x = [Foo, String, Cmp, Comparable, 1]
p x.map { |c| c.is_a?(Module) }
p x.map { |c| c.kind_of?(Module) }
p x.map { |c| c.is_a?(Class) }
p x.map { |c| c.instance_of?(Module) }
p x.map { |c| Module === c }
def kind(v)
  case v
  when Module then "module-ish #{v}"
  else "other"
  end
end
x.each { |v| puts kind(v) }
