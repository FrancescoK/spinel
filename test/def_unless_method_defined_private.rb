# method_defined? does not see a private method, so a def guarded by it
# still runs after a `private def` of the same name, while a protected def,
# or a private one made public again, counts as defined.
class A
  private def m = :priv
  def m = :guarded unless method_defined?(:m)

  private def q = :was_private
  public :q
  def q = :guarded unless method_defined?(:q)

  protected def r = :prot
  def r = :guarded unless method_defined?(:r)

  def all = [m, q, r]
end

class B < A
  private def s = :priv
  def s = :guarded unless public_method_defined?(:s)
  def t = s
end
p A.new.all, B.new.t
