module M
  def hi = "M>" + super
end
class K
  def self.hi = "K"
  p hi
  singleton_class.prepend(M)
  p hi
end
p K.hi
