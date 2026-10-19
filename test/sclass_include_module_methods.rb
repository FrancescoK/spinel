# `class << self; include M; end` makes M's methods the class's own class
# methods, as `extend M` does: a class method written beside it calls them
# and answers what they answer, a method of the singleton body itself comes
# ahead of M's, and `prepend M` there puts M in front.

class Rewriter
  def initialize = @n = 0
  def bump = (@n += 1; self)
  attr_reader :n
end

module Helper
  def edit_branches(rw, node)
    rw.bump
    tag(node)
    rw
  end

  def tag(node) = "helper #{node}"
  def who = :helper
end

module Loud
  def who = :loud
end

class IfEdit
  class << self
    include Helper
    def apply(rw, node) = edit_branches(rw, node)
    def who = :ifc
  end
end

class PrepC
  class << self
    prepend Loud
    def who = :prepc
  end
end

module Mod
  class << self
    include Helper, Loud
    def run(r) = edit_branches(r, :mod).n
  end
end

class CaseEdit
  def self.apply(rw, node) = rw.bump
end

def move(rw, node)
  if node == :if
    IfEdit.apply(rw, node)
  else
    CaseEdit.apply(rw, node)
  end
end

p move(Rewriter.new, :if).n
p move(Rewriter.new, :case).n
p IfEdit.who, IfEdit.tag(:x)
p PrepC.who
p Mod.run(Rewriter.new), Mod.who

# after a method of the singleton body: a declaration runs nothing that
# could see M missing
class LateInc
  class << self
    def own = :own
    include Helper
  end
end
p LateInc.own, LateInc.who
