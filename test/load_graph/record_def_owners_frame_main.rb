# A def's owner is the class of the frame it is written in, whether or
# not a load point applies it: a def in a class_eval block inside
# `class << C` is a class method of C, and a def in an iterator's block or
# under a condition in a class body is the class's. A define_method
# unrolled over computed names in a Struct.new block, also in the taken
# arm of a constant condition and in a block built in a method, defines
# on the struct's class.
class C
end
class << C
  class_eval do
    def made = "C.made"
  end
end

class K
  [1].each { def from_iter = :iter }
  if ENV["SPINEL_NO_SUCH_VAR"] then def cond_m = :c1 else def cond_m = :c2 end
  def self.mk
    def inner_m = :inner
  end
end

S = Struct.new(:a) do
  if true
    %i[r s].each { |v| define_method("get_#{v}") { v } }
  end
  unless false
    %i[t].each { |v| define_method("got_#{v}") { v } }
  end
end

def build
  Struct.new(:b) do
    %i[u w].each { |v| define_method("h_#{v}") { v } }
  end
end
B = build

p C.made
p C.respond_to?(:made), C.new.respond_to?(:made)
p K.new.from_iter, K.new.cond_m
K.mk
p K.new.inner_m
s = S.new(1)
p s.get_r, s.get_s, s.got_t
p B.new(2).h_u, B.new(2).h_w
