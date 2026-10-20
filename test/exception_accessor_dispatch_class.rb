# A Class read out of an Array answers its own key / result class methods
# (inherited ones too) instead of the exception accessors of those names.
class Cfg
  def self.key = :k
  def self.result = :r
end
k = [Cfg, 0][0]
p [k.key, k.result]
class Parent2
  def self.result = :inherited
end
class Child2 < Parent2; end
kc = [Child2, 0][0]
p kc.result
