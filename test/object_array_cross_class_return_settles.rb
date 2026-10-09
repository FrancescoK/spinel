# A class method a base class defines builds an Array of what each
# subclass's hook answers; another class's method returns the subclass's
# call as its own value (#7993). The two return slots settle on one verdict:
# boxed where the caller's value reaches a dynamic receiver, the object
# array where every use is vetted. Inference used to trade the verdict
# between them every round until the cap and then refused the program.
module Db
  def self.prepare(s) = [s, 0]
  def self.step?(st)
    st[1] += 1
    st[1] <= 2
  end
  def self.finalize(st) = nil
  def self.column_int(st, i) = st[1] * 10 + i
  def self.column_text(st, i) = "n#{st[1]}"
  def self.escape_int(i) = i.to_s
end
module Sqlx
  class Base
    def self.find_by_sql(sql)
      stmt = Db.prepare(sql)
      results = []
      while Db.step?(stmt)
        results << from_stmt(stmt)
      end
      Db.finalize(stmt)
      results
    end
    def self.from_stmt(_stmt)
      raise NotImplementedError, "from_stmt: subclasses must override"
    end
  end
end
class Subscription < Sqlx::Base
  attr_reader :id, :name
  def initialize(h) = (@id = h[:id]; @name = h[:name])
  def self.from_stmt(stmt)
    Subscription.new({ id: Db.column_int(stmt, 0), name: Db.column_text(stmt, 1) })
  end
end
class User < Sqlx::Base
  attr_reader :id
  def initialize(h) = @id = h[:id]
  def self.from_stmt(stmt) = User.new({ id: Db.column_int(stmt, 0) })
  def subscriptions
    Subscription.find_by_sql("SELECT id, name FROM subscriptions WHERE user_id = " + Db.escape_int(@id))
  end
end
u = User.find_by_sql("select").first
p u.subscriptions.map(&:name)
v = User.new({ id: 1 })
s = v.subscriptions
p s.map(&:name)
p s.length
p v.subscriptions.map(&:id)
