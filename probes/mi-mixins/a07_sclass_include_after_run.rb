module M
  def hi = "M"
end
class K
  class << self
    p respond_to?(:hi)
    include M
    p respond_to?(:hi)
  end
end
p K.hi
