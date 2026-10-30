# spinel: not-cruby
# Compile check: every guard arm and super target must have a declaration.
# Reopening a prepended module still stacks both copies, as on the base.
# CRuby instead prints "k", "L1 k", "L2 k".
module L
  def m = "L1 " + super
end
class K
  def m = "k"
end
k = K.new
def call(k) = k.m
p call(k)
class K; prepend L; end
p call(k)
module L
  def m = "L2 " + super
end
p call(k)
