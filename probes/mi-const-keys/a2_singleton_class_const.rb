class A
  X = 1
  class << self
    X = 2
    def x = X
  end
  def self.y = X
end
p A::X, A.x, A.y
