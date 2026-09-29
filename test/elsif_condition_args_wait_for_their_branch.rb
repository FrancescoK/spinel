# The arguments of a call in an elsif condition are evaluated only when
# that condition is reached, never before an earlier branch that is taken.
class Store
  def fetch(tag, value) = value
end

class Record
  attr_accessor :id

  def initialize
    @log = []
  end

  def insert_args
    @log << "insert_args"
    1
  end

  def update_args
    @log << "update_args"
    raise "update_args with a nil id" if @id.nil?
    @id
  end

  def save(store)
    if id.nil?
      self.id = store.fetch("insert", insert_args)
    elsif store.fetch("update", update_args)
      @log << "updated"
    end
    @log.join(",")
  end
end

store = Store.new
record = Record.new
puts record.save(store)
puts record.save(store)

def pick(x, store)
  if x == 1
    "one"
  elsif store.fetch("two", x == 2)
    "two"
  elsif store.fetch("three", x == 3)
    "three"
  else
    "other"
  end
end
puts [1, 2, 3, 4].map { |x| pick(x, store) }.join(" ")
