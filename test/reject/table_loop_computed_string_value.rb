# A String the loop computes is a new, unfrozen object in CRuby, so
# `M::N1 << "!"` works there. The inline model's text pass would write it
# out frozen, so it leaves the loop as written, which Spinel refuses. The
# analysis answers it (test/analysis-forms/, the same name).
module M
  class Base; end
  T = { 1 => "O ne" }
  T.each { |c, n| const_set("N#{c}", n.gsub(/ /, "")); const_set(n.gsub(/ /, ""), Class.new(Base)) }
end
M::N1 << "!"
p M::N1
