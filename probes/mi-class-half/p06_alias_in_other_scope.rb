module Outer
  class Util
    def self.five = 5
  end
end
class Util
  def self.five = 50
end
module N
  X = Outer::Util
  def self.f = X.five
end
p N.f
p Util.five
