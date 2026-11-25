# A Method of a class method made on a receiver of several classes holds
# the lowering's wrapper, which takes its receiver as its first parameter
# and picks the method by that receiver's class where it runs. Bound to a
# Class value, which is no object pointer, it is refused, as an
# UnboundMethod#bind the wrapper cannot run.
class K; def self.cm(x) = [:k, x]; end
class L < K; end
[K, L].each { |o| p o.method(:cm).unbind.bind(L).call(4) }
