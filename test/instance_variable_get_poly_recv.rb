# instance_variable_get with a literal :@name on a receiver whose static
# type is poly: dispatch the field read over every instantiated class that
# owns the slot, unifying the declared slot types (mixed types stay poly,
# a single shared type stays concrete).

# spinel: infer-ivar-get
class Grid
  def initialize
    @columns = [["a", 1], ["b", 2], ["c", 3]]
  end
end

class Table
  def initialize
    @columns = { "w" => "hash-w", "h" => "hash-h" }
  end
end

class Deck
  def initialize
    @rows = [10, 20, 30]
  end
end

class Pile
  def initialize
    @rows = [7, 8]
  end
end

class Manager
  # called with Grid and Table, so obj unifies to poly; the slot types
  # differ (array vs hash), so the result stays poly too
  def describe(obj)
    cols = obj.instance_variable_get(:@columns)
    puts cols.length
    if obj.is_a?(Grid)
      p cols[0]
    else
      p cols["w"]
    end
  end

  # called with Deck and Pile, so obj unifies to poly; both slots are
  # integer arrays, so the unified result type is concrete
  def row_info(obj)
    rows = obj.instance_variable_get(:@rows)
    puts rows.length
    puts rows[1]
  end
end

m = Manager.new
m.describe(Grid.new)
m.describe(Table.new)
m.row_info(Deck.new)
m.row_info(Pile.new)
