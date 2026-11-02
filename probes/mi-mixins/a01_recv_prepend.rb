module M
  def hi = "M" + super
end
class K
  def hi = "K"
end
p K.new.hi
K.prepend(M)
p K.new.hi
p K.ancestors.take(3)
