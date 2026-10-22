# A block on a reader call does not bypass the planned subclass method.
class PlanBox
  attr_reader :items
  def initialize = @items = [3, 1, 2]
  def run = items { 0 }
end
class PlanSubBox < PlanBox
  def items = super.reverse
end
p PlanBox.new.run, PlanSubBox.new.run
class PlanReopenedBox < PlanBox; end
class PlanReopenedBox
  def items = super.reverse
end
p PlanReopenedBox.new.run

# Alias-only descendants also belong to the reader's planned target set.
class PlanAliasParent
  attr_reader :items
  def initialize = @items = [3, 1, 2]
  def run = items { 0 }
end
class PlanAliasBox < PlanAliasParent
  def reversed_items = @items.reverse
  alias items reversed_items
end
class PlanReopenedAliasBox < PlanAliasParent
  def reversed_items = @items.reverse
end
class PlanReopenedAliasBox
  alias_method :items, :reversed_items
end
p PlanAliasBox.new.run, PlanReopenedAliasBox.new.run

# An override taking the block as a parameter receives the call's block.
class PlanProcParent
  attr_reader :items
  def initialize = @items = [3, 1, 2]
  def run = items { |x| x * 10 }
end
class PlanProcBox < PlanProcParent
  def items(&blk) = blk ? @items.map(&blk) : @items
end
p PlanProcParent.new.run, PlanProcBox.new.run
