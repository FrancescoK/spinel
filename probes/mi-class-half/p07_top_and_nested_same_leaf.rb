class Leaf
  def w = :top
end
module M
  class Leaf
    def w = :m
  end
  def self.mk = Leaf.new.w
end
p Leaf.new.w, M::Leaf.new.w, M.mk
