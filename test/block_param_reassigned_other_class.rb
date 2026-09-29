# A block parameter the body rebinds to an object of another class widens
# like any local; the write was forced into the yielded type and raised
# TypeError. (sqlite3's `prepare(sql) do |stmt| stmt = build(stmt) ...`.)
class St
  def rows = [1, 2]
end
class RS
  def initialize(s) = @s = s
  def to_a = @s.rows.map { |x| x * 10 }
end
class Db
  def prepare
    yield St.new
  end
  def build(st) = RS.new(st)
  def execute
    prepare do |stmt|
      stmt = build stmt
      stmt.to_a
    end
  end
end
p Db.new.execute
