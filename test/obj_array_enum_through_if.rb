# An object array that reaches a local through an `if` value: the local and
# the branches narrow together or not at all, so every call on it compiles.
class Row
  attr_reader :id
  def initialize(id) = @id = id
end

def hydrate(n)
  out = []
  out << Row.new(2)
  out << Row.new(1) if n > 0
  out
end

def load_rows(flag)
  rows = if flag then hydrate(1) else hydrate(0) end
  rows
end

rows = load_rows(true)
p [1, 2, 3].map { |key| rows.find { |row| row.id == key } }.map { |r| r && r.id }
p rows.select { |r| r.id > 1 }.map(&:id)
p rows.any? { |r| r.id == 1 }
p rows.min_by(&:id).id
p load_rows(false).find { |r| r.id == 1 }
