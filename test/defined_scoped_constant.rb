# defined?(P::n) looks n up in P and P's ancestors but not in Object, so a
# top-level constant is not P::n. spinel checked each segment's name alone
# and answered "constant" for defined?(Mod::String).
class K; X = 1; end
class S < K; end
module M; Y = 2; end
class C; include M; end
module Spec
  class Basic; end
end
p defined?(K::String), defined?(S::X), defined?(C::Y), defined?(K::Nope)
p defined?(M::Comparable), defined?(Object::String)
p defined?(Spec::String), defined?(Spec::Basic::String), defined?(Spec::Basic)
p defined?(String), defined?(::String), defined?(M::Y)
module Spec
  self::Scoped = 42
end
p defined?(Spec::Scoped)
