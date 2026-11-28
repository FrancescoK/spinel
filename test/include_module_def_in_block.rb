# A module's method whose block holds a def, copied into the class that
# includes it: walking the copy makes the def's scope, which may move the
# table of scopes the copy's own entries point into. The compile read them
# after the move and aborted, or answered NoMethodError, now and then.
class Y; def initialize = (@b = block_given? ? yield : :none); attr_reader :b; end
module M
  def mk = self.class.new { def md = :md; 6 }
  def mv = self.class.new { 8 }
end
class Y; include M; end
p Y.new.mk.b, Y.new.md, Y.new.mv.b
