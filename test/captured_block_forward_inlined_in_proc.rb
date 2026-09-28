class Tx
  def within_transaction(&) = yield
end

class Coll
  def initialize(items) = @items = items

  def perform(&)
    within_transaction { run_callbacks(&) }
  end

  def perform_named(&blk)
    within_transaction { run_callbacks(&blk) }
  end

  def run_callbacks
    block_given? ? yield : :none
  end

  def within_transaction
    @items.first.within_transaction { yield }
  end
end

coll = Coll.new([Tx.new, 1])
p coll.perform
p coll.perform { :given }
p coll.perform_named { :named }
