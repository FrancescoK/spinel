# `extend self` is the other spelling of module_function: every method of the
# module is callable on the module itself. Unlike module_function's bare form
# the placement carries no meaning -- it applies to the whole body, before and
# after -- and the methods stay callable as instance methods when the module
# is included.
module Fmt
  extend self

  def upcase_all(xs) = xs.map { |x| x.upcase }

  def join(xs, sep = ", ") = upcase_all(xs).join(sep)
end

p Fmt.upcase_all(["a", "b"])
p Fmt.join(["a", "b"])
p Fmt.join(["a", "b"], "-")

# the marker below the defs it governs
module Rev
  def twice(s) = s + s
  extend self
end
p Rev.twice("ab")
