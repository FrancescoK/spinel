# A Method of a builtin's method made on a receiver of several builtin
# classes holds the lowering's wrapper (see
# method_bind_poly_recv_class_method.rb). Bound to that boxed receiver, it
# is refused.
p [1, "a"].map { |o| o.method(:to_s).unbind.bind(o).call }
