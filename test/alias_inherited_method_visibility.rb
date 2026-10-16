# An alias of an inherited method takes the visibility of the method it
# names, not that of the `private` section it sits in; a later `private`
# naming the alias still makes it private.
class P
  def m = 1
  def pm = 3
  private :pm
end
class D < P
  private
  alias hid m
  alias_method :hid2, :m
  alias phid pm
  alias later m
  public
  private :later
  def via = [phid, later]
end
d = D.new
p d.hid, d.hid2, d.via
p D.private_instance_methods(false).sort, D.public_instance_methods(false).sort
[:phid, :later].each do |m|
  begin
    d.public_send(m)
  rescue NoMethodError => e
    p [m, e.class]
  end
end
