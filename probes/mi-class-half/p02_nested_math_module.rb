module M
  module Math
    def self.pi2 = 6
  end
end
p M::Math.pi2
p Math.respond_to?(:pi2)
