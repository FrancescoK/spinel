class B
  def self.r = defined?(W) ? W : :none
end
class C
  W = 5
end
p B.r, C::W
