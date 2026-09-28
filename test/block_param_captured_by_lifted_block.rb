class Tx
  def within_transaction(&) = yield
end

class Coll
  def initialize(items) = @items = items

  def perform(&)
    return :blockless unless block_given?
    within_transaction { run_callbacks(&) }
  end

  def perform_named(&blk)
    return :blockless unless block_given?
    within_transaction { run_callbacks(&blk) }
  end

  def run_callbacks(depth = 0, &)
    depth < @items.size ? run_callbacks(depth + 1, &) : yield
  end

  def within_transaction
    @items.first.within_transaction { yield }
  end

  def deferred(&b)
    return :none unless block_given?
    pr = proc { b.call }
    pr.call
  end
end

coll = Coll.new([Tx.new, 1])
p coll.perform
p coll.perform { :given }
p coll.perform_named { :named }
p coll.deferred
p coll.deferred { :deferred }
