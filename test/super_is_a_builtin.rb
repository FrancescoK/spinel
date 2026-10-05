# `super` in an is_a? / kind_of? / instance_of? override that no ancestor
# defines is Object's own answer for this object. activesupport's
# TimeWithZone says it is a Time this way (`klass == ::Time || super`). It
# raised NoMethodError for a missing superclass method, and the C did not
# compile where the raise met the bool beside it.
class Base
  include Comparable
  def <=>(o) = 0
end
class Zoned < Base
  def is_a?(klass)
    klass == ::Time || super
  end
  alias_method :kind_of?, :is_a?
  def instance_of?(klass) = super
end
z = Zoned.new
p z.is_a?(Time)
p z.is_a?(Zoned)
p z.is_a?(Base)
p z.is_a?(Object)
p z.is_a?(Comparable)
p z.is_a?(String)
p z.kind_of?(Base)
p z.instance_of?(Zoned)
p z.instance_of?(Base)
