# An alias of Object#respond_to? in a class that does not define its own
# calls the builtin, and respond_to? answers the alias's name too, as it
# does an alias of dup.
class K
  def initialize = @x = 1
  def known = 1
  alias orig respond_to?
  alias copy dup
end
k = K.new
p k.orig(:orig), k.orig(:known), k.orig(:zz)
p k.respond_to?(:copy), k.respond_to?(:orig)
p [:orig, :copy, :zz].map { |m| k.respond_to?(m) }
