# A method that `extend` transplants onto a module keeps its splat parameter's
# type: `*syms` is an Array by construction, in the clone as in the source.
# Typed as nothing, the hash built from it (and the constant holding that hash)
# vanished -- the ffi gem's `enum(:a, :b, :c)` inside `extend FFI::Library`.
module Lib
  def mk(*syms); h = {}; syms.each_with_index { |s, i| h[s] = i }; h; end
  def opts(**kw) = kw.keys
end
module Ort
  extend Lib
  E = mk(:a, :b, :c)
  K = opts(x: 1, y: 2)
end
p Ort::E
p Ort::K
p Ort.mk(:z)
