# instance_variable_set(:@x, v) with a literal name: nil into an Integer slot
# is nil (it wrote 0), and on a receiver typed poly the write reaches the
# receiver's class (it raised NoMethodError). sqlite3's
# `@db.instance_variable_set(:@stmt_deadline, nil)`.
class Db
  def initialize = @stmt_deadline = 5
  def d = @stmt_deadline
end
class Stmt
  def initialize(db) = @db = db
  def reset = @db.instance_variable_set(:@stmt_deadline, nil)
end
db = Db.new
Stmt.new(db).reset
p db.d
objs = [db, Stmt.new(db), 3]
p objs[0].instance_variable_set(:@stmt_deadline, 9)
p db.d
objs[0].instance_variable_set(:@stmt_deadline, nil)
p db.d
