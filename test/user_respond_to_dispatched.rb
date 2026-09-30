# A class's own respond_to? answers for its instances -- the compile-time
# fold used to answer from the method table instead, so an override that
# claims a name the table has not (`m == :magic`, backed by method_missing
# in real code) read false, and one that denies a name the table has read
# true. activesupport's TimeWithZone overrides respond_to? this way.

class Dyn
  def respond_to?(m, include_all = false) = m == :magic || m == :to_s
  def hidden = 1
end
d = Dyn.new
p d.respond_to?(:magic), d.respond_to?(:other), d.respond_to?(:to_s)
p d.respond_to?(:hidden)

class Inner
  def respond_to?(m, include_all = false) = m == :shown
  def check = respond_to?(:shown) && !respond_to?(:check)
end
p Inner.new.check
