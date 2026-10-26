module A
  def hi = "A"
end
class Greeter
  include A
end
class Box
  include M2
end
