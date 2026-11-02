class Red; def w = :red; end
class Blue; def w = :blue; end
module X
  C = Red
  def self.w = C.new.w
end
module Y
  C = Blue
  def self.w = C.new.w
end
p X.w, Y.w, X::C.new.w, Y::C.new.w
