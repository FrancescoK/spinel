module M
  class Inner
    def self.hi = :hi
  end
end
begin
  p Inner.hi
rescue NameError => e
  p e.class
end
p M::Inner.hi
