# A lambda call's result passed as an argument types the parameter from the
# lambda's settled return, so an ivar built from that parameter keeps the
# typed array it gets at runtime.
class K; def initialize(a:, b:) = (@v = [a, b]); attr_reader :v; end
p K.new(a: 3, b: ->(z) { z + 1 }.call(1)).v

class K2; def initialize(a, b) = (@v = [a, b]); attr_reader :v; end
p K2.new(3, ->(z) { z * 2 }.(4)).v

class K3; def set(a, b) = (@v = [a, b]); attr_reader :v; end
k = K3.new
l = ->(s) { s.upcase }
k.set("x", l.call("y"))
p k.v

class K4; def initialize(a) = (@h = { a => ->(z) { z + 1 }[a] }); attr_reader :h; end
p K4.new(5).h
