# sqlite3-ruby 2.9.5 through its C extension compiled from source (#7210):
# tables, binds by position and name, blobs and text, prepared statements,
# functions and the C aggregator, collations, transactions, errors with
# their code and SQL offset, the authorizer, pragmas and a backup.
require "sqlite3"

p SQLite3::SQLITE_VERSION_NUMBER > 3000000
p SQLite3.libversion > 3000000
p SQLite3.threadsafe?

db = SQLite3::Database.new(":memory:")
p db.encoding.to_s
db.execute("create table items (id integer primary key, name text, price real, data blob, note text)")
db.execute("insert into items (name, price, data, note) values (?, ?, ?, ?)", ["apple", 1.5, SQLite3::Blob.new("\x00\x01\xFF".b), nil])
db.execute("insert into items (name, price, data, note) values (:name, :price, :data, :note)",
           {name: "pear", price: 2, data: "plain", note: "fresh"})
p db.changes
p db.last_insert_row_id

rows = db.execute("select id, name, price, data, note from items order by id")
rows.each do |id, name, price, data, note|
  p [id, name, price, data.encoding.to_s, data.bytes.length, note]
end
p rows[0][3].frozen?

db.execute("select name from items where price > ?", [1.0]) { |row| p row }

db.results_as_hash = true
p db.execute("select id, name from items where id = 1")
db.results_as_hash = false

stmt = db.prepare("select name, price from items where price >= ?")
p stmt.columns
p stmt.bind_params(1.5)
p stmt.execute.to_a
stmt.reset!
stmt.bind_param(1, 2.0)
p stmt.step
p stmt.done?
stmt.close
p stmt.closed?

p db.get_first_value("select count(*) from items")
p db.get_first_row("select name, price from items order by price desc")
p db.execute("select typeof(?), typeof(?), typeof(?), typeof(?)", [1, 1.5, "s", nil])

db.create_function("plus_one", 1) { |fn, x| fn.result = x + 1 }
p db.execute("select plus_one(41)")
db.create_function("concat2", 2) { |fn, a, b| fn.result = "#{a}-#{b}" }
p db.execute("select concat2('a', 'b')")

class Summer
  def self.arity = 1
  def initialize = @sum = 0
  def step(v) = @sum += v
  def finalize = @sum
end
# the C aggregator (define_aggregator2) with a class whose instances step and
# finalize: the Ruby wrappers build a class per call (Class.new with a block),
# which Spinel does not compile
db.send(:define_aggregator2, Summer, "summer")
p db.execute("select summer(price) from items")
p db.execute("select summer(price) from items where price > 100")

db.collation("backwards", Class.new do
  def compare(a, b) = b <=> a
end.new)
p db.execute("select name from items order by name collate backwards")

db.transaction do
  db.execute("insert into items (name, price) values ('fig', 3.25)")
end
p db.get_first_value("select count(*) from items")
begin
  db.transaction do
    db.execute("insert into items (name, price) values ('kiwi', 4)")
    raise "undo"
  end
rescue => e
  p e.message
end
p db.get_first_value("select count(*) from items")

begin
  db.execute("select * frm items")
rescue SQLite3::SQLException => e
  puts e.message
  p e.code
end
begin
  db.execute("insert into items (id, name) values (1, 'dup')")
rescue SQLite3::ConstraintException => e
  p e.class
  p e.message
end

p db.complete?("select 1;")
p db.complete?("select 1")
p db.table_info("items").map { |c| c["name"] }
p db.execute2("select id, name from items where id < 3")

db.authorizer = ->(action, a, b, c, d) { action == 9 && a == "items" ? 1 : 0 }
begin
  db.execute("delete from items where id = 2")
rescue SQLite3::AuthorizationException => e
  p e.class
end
db.authorizer = nil
db.execute("delete from items where id = 2")
p db.changes

count = 0
db.busy_handler { |tries| count += 1; tries < 2 }
db.busy_timeout = 10
p db.statement_timeout = 50

db.trace { |sql| }
p db.execute("select 1 + 1").flatten
p db.readonly?
p db.closed?
db.close
p db.closed?
begin
  db.execute("select 1")
rescue ArgumentError, SQLite3::Exception => e
  p [e.class, e.message]
end

file = SQLite3::Database.new(":memory:")
src = SQLite3::Database.new(":memory:")
src.execute("create table t (a)")
src.execute("insert into t values (7)")
b = SQLite3::Backup.new(file, "main", src, "main")
p b.step(-1)
b.finish
p file.execute("select a from t")
file.close
src.close
