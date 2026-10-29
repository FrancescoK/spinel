# Calls through send look up the live definition when they run.

module L1
  def speak = "L1 " + super
end
class D1
  def speak = "d"
end
d = D1.new
p d.send(:speak), d.public_send(:speak), d.__send__(:speak)
class D1
  prepend L1
end
p d.send(:speak), d.public_send(:speak), d.__send__(:speak)

module L6
  def speak = "L6 " + super
end
class D6
  def speak = "d"
end
d = D6.new
n = :speak; p d.send(n), d.public_send(n), d.__send__(n)
class D6
  prepend L6
end
n = :speak; p d.send(n), d.public_send(n), d.__send__(n)
