# A class_eval's text runs where the eval stands: a call in it after its
# method's def finds the method, in a class body and in a hook's text.
class U
  def self.zz = 5
  class_eval "X = zz"
  class_eval "Y = zz() + 1"
end
p U::X, U::Y

module M
  def self.included(base) = base.class_eval { class_eval "Z = zz" }
end
class V
  def self.zz = 7
  include M
end
p V::Z
