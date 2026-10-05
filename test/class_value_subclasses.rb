# Class#subclasses on a class known only at run time -- a parameter, an
# element -- answers that class's subclasses, as on a constant.
# activesupport's Class#descendants walks `subclasses.flat_map(&:descendants)`.
# It was refused for any receiver but a constant.
class A; end
class B < A; end
class C < B; end
class D < A; end
def kids(c) = c.subclasses.map(&:name).sort
def walk(c) = c.subclasses.flat_map { |k| [k.name] + walk(k) }.sort
p kids(A)
p kids(B)
p kids(C)
p walk(A)
