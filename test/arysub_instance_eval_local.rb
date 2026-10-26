# instance_eval on a local Array, Hash or String subclass instance: the
# receiver's class is known only after inference, and the block's bare
# builtin calls still reach it.

class A < Array; end
a = A.new([1, 2])
p a.instance_eval { size }
class S < String; end
s = S.new("ab")
p s.instance_eval { size }
class H < Hash; end
h = H.new
h[:a] = 1
p h.instance_eval { keys }
p h.instance_eval { fetch(:a) }
p h.instance_eval { key?(:a) }
h.instance_eval { each { |k, v| p [k, v] } }
