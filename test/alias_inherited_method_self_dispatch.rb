# alias_method of an inherited method in a subclass is what `self.<alias>`
# reaches from an inherited method: HRS#each (inherited) must call HRS's
# `next`, the aliased next_hash, not RS#next. (sqlite3's HashResultSet.)
class RS
  def initialize = @i = 0
  def next
    @i += 1
    @i > 2 ? nil : [@i]
  end
  def next_hash
    row = [@i += 1]
    @i > 2 ? nil : {"v" => row[0]}
  end
  def each
    while (node = self.next)
      yield node
    end
  end
end
class HRS < RS
  alias_method :next, :next_hash
end
RS.new.each { |r| p r }
HRS.new.each { |r| p r }
p HRS.new.next
