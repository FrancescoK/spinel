# An attr_reader in a subclass over a method its superclass (or a module it
# includes) defines answers for the subclass's objects, through a call in
# the superclass's own methods as well.
class Node
  def receiver = nil
  def label = "node"
  def call_type? = false

  def describe
    receiver.nil? ? [label, :leaf] : [label, :call, receiver.describe]
  end
end

class Call < Node
  attr_reader :receiver, :name
  attr_accessor :label

  def initialize(recv, label)
    @receiver = recv
    @label = label
  end
end

class Lit < Node
end

class Block < Node
  def receiver = Lit.new
end

module Named
  def title = "untitled"
  def show = "<#{title}>"
end

class Doc
  include Named
  attr :title

  def initialize(t) = @title = t
end

class Page < Doc
  def initialize = super("page")
end

p Call.new(Lit.new, "send").describe
p Call.new(Call.new(nil, "inner"), "outer").describe
p Lit.new.describe
p Block.new.describe
s = Call.new(Lit.new, "x")
s.label = "relabeled"
p s.describe.first
p Doc.new("doc").show, Page.new.show
