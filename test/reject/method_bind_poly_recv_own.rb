# A Method of a program class's method made on a receiver of several
# classes holds the lowering's wrapper (see
# method_bind_poly_recv_class_method.rb). Bound back to that boxed
# receiver, it is refused.
class K; def cm(x) = [:k, x]; end
class L < K; def cm(x) = [:l, x]; end
[K.new, L.new].each { |o| p o.method(:cm).unbind.bind(o).call(4) }
