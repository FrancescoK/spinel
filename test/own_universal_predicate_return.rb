# A class's own is_a?, instance_of?, kind_of?, ==, !=, nil?, equal? or
# frozen? is the method a call on one of its instances reaches, and its
# value is whatever that method returns -- which need not be true or false.
# The call was typed as the builtin predicate's boolean, so a non-boolean
# answer went into a C boolean and the C did not build.
class OwnPred
  def initialize(v) = @v = v
  def instance_of?(k) = k == OwnPred ? :tag : nil
  def is_a?(k) = k == OwnPred ? 1 : false
  def kind_of?(k) = is_a?(k)
  def ==(o) = o.is_a?(OwnPred) ? "same" : nil
  def nil? = "never"
  def frozen? = @v
end

o = OwnPred.new(:cold)
p o.instance_of?(OwnPred), o.instance_of?(String)
p o.is_a?(OwnPred), o.kind_of?(Integer)
p o == OwnPred.new(1), o == 3
p o.nil?, o.frozen?
