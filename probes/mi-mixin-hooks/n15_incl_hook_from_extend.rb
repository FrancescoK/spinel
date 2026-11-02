# included: the hook comes from a module M extends, added after the first include
module Hooks
  def included(b) = puts("hooked #{b}")
end
module M; end
class A; include M; end
M.extend(Hooks)
class B; include M; end
puts "done"
