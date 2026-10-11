# A count(arg) on a receiver of several classes, one of whose count can
# answer nil: the String arm's count goes into the nullable result (#8492).
class MemoryAdapter
  def count(table)
    table.length
  end
end

class NullAdapter
  def count(table)
    table.empty? ? nil : 0
  end
end

module Store
  @adapter = MemoryAdapter.new

  def self.adapter
    @adapter
  end

  def self.adapter=(a)
    @adapter = a
  end
end

class Base
  def self.table_name
    "posts"
  end

  def self.count
    Store.adapter.count(table_name)
  end
end

p Base.count
Store.adapter = NullAdapter.new
p Base.count
Store.adapter = "spot"
p Base.count
