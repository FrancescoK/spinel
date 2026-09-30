# A String bang mutator whose receiver is a reader call and whose value is
# used mutates the String the reader answers, once (#6436)
class Provider
  attr_accessor :subdomain
  def initialize(subdomain)
    @subdomain = subdomain
  end
  def tidy; subdomain.strip!; end
  def tidy_and; subdomain && subdomain.strip!; end
end

p1 = Provider.new(" acme ".dup)
x = p1.subdomain.strip!
p x
p p1.subdomain
p p1.subdomain.strip!          # no change: nil
p p1.subdomain

p2 = Provider.new(" b ".dup)
p p2.tidy, p2.subdomain
p3 = Provider.new(" c ".dup)
p p3.tidy_and, p3.subdomain

class Named
  def initialize(n) = @name = n
  def name; @name; end
end
n = Named.new(" acme ".dup)
y = n.name.upcase!
p y, n.name
z = n.name.gsub!("C", "k")
p z, n.name
p n.name.sub!("zzz", "y"), n.name
p n.name.reverse!, n.name

