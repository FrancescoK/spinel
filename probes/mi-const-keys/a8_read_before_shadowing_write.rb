X = 1
class A
  Y = X
  X = 2
  def self.z = [Y, X]
end
p A.z, X
