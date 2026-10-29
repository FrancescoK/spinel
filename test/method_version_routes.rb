# Method lookup observes redefinitions at call or capture time.
class D; def speak = "d"; end
d = D.new
class E < D; def speak = "e " + super(); end
p E.new.speak, d.method(:speak).call, D.instance_method(:speak).bind(d).call
class D; def speak = "d2"; end
p E.new.speak, d.method(:speak).call
