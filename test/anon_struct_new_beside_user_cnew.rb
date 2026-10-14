# `Struct.new(...).new(...)` -- or `new` on a local holding that anonymous
# Struct -- builds the Struct even where some other class defines its own
# `self.new`: the receiver names the class, so no class-method dispatch
# over the classes with a `self.new` is asked

class V
  def self.new(x) = nil
end

S = Struct.new(:for_lockfile).new "!"
p S
p S.for_lockfile
A = Struct.new(:a, :b).new(1, 2)
p A
B = Struct.new(:x, keyword_init: true).new(x: 3)
p B
k = Struct.new(:z)
p k.new(4)
D = Data.define(:w).new(w: 5)
p D
p V.new(1)
