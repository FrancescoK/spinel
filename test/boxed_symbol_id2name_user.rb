# A program class answering id2name -- its own method or an attr_reader --
# keeps its answer when read out of a mixed Array, and a boxed Symbol beside
# it still answers its name. The boxed Symbol arm (#7422) stands down here.
class Named
  def id2name = "named"
end
class Held
  attr_reader :id2name
  def initialize(n) = @id2name = n
end
p [Named.new, :a][0].id2name
p [Held.new("held"), :a][0].id2name
p [:sym, Named.new][0].id2name
p [:sym, Held.new("x")][0].id2name
