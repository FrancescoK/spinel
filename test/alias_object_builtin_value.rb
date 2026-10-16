# An alias of dup / clone in a class whose instances are values (no
# mutable state) copies through the builtin, bare or on self, past the
# class's own method of the name defined after the alias.
class Val
  alias old_dup dup
  alias old_clone clone
  def initialize = (@v = 7)
  def v = @v
  def bare = old_dup
  def on_self = self.old_clone
  def dup = "own dup"
  def clone = "own clone"
end
vd = Val.new.bare
p vd.v
p Val.new.on_self.v
