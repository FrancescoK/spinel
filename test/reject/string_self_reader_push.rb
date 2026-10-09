# spinel: reject-share
# Storing an implicit-self reader must keep the instance variable's String.
# The default build cannot carry that handle into the Array.
class K
  attr_reader :n
  def initialize = (@n = +"n")
  def m
    a = []
    a << n
    a[0] << "!"
    a
  end
end
k = K.new
k.m
p k.n
