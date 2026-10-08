# X is defined only as A::X and B's lookup does not reach it, but B defines
# const_missing, which CRuby calls for the miss: spinel does not follow it,
# so the read is refused where it is written.
module A
  class X; end
end
class B
  def self.const_missing(name) = name
  def self.get = X
end
p B.get
