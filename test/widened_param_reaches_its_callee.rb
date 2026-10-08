# A parameter widened to poly after the main fixpoint (Pool#insert, reached
# only through a poly receiver) is an argument to the methods it calls. It
# used to bind nothing there, so Connection#execute's `binds` was typed from
# a dead caller that passes an Array of Strings. The live Array of an Integer
# and nil was converted to a String array at the call, its Integer was read
# as a string pointer, and `include?` on it crashed.
#
# The dead caller's Array only types as String because a user class defines
# a yielding `each`; the stored-proc call is what leaves Pool#insert's
# receiver poly.
# spinel: share
def check_binds(binds)
  binds.each do |value|
    puts "bind: #{value.class}"
    case value
    when String
      puts "NUL" if value.include?("\0")
    end
  end
end

class Connection
  def execute(sql, binds) = check_binds(binds)
end

class Pool
  def insert(sql, binds) = Connection.new.execute(sql, binds)
end

class Post
  attr_accessor :id, :created_at

  def insert_binds = [@created_at, nil]

  def save(db)
    @created_at = 1790589111
    self.id = db.insert("INSERT", insert_binds)
  end
end

class Migrator
  def migrate
    @migrations.each { |migration| @conn.execute("INSERT", [migration.version]) }
  end
end

class Migration
  def version = "20260928000001"
end

class Errors
  def each
    yield 1
  end
end

class Endpoint
  def initialize(handler) = @handler = handler
  def call(a, b) = @handler.call(a, b)
end

def post_endpoint(&handler) = Endpoint.new(handler)

ep = post_endpoint { |c, r| Post.new.save(c) ? 303 : 422 }
puts ep.call(Pool.new, 0)
