# `class A::B` puts only A::B in the body's lexical scope, not A: reading
# LIMIT there raises NameError (uninitialized constant A::B::LIMIT) when it
# runs, as in CRuby. spinel read A::LIMIT, and later refused the program.
module A
  LIMIT = 3
end
class A::B
  def self.limit = LIMIT
end
begin
  p A::B.limit
rescue NameError => e
  p e.message
end
p A::LIMIT
