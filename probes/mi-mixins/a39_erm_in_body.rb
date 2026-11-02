module M
  def hi = :m
end
class K
  K.include(M)
end
module N
  K.include(Comparable)
end
p K.new.hi
p K.include?(Comparable)
