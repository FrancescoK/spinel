module M
  class Impl
    def w = :impl
  end
end
module N
  def self.f = K.new.w
  K = M::Impl
end
p N.f
