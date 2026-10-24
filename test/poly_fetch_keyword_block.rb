# fetch with keyword arguments and a block on a receiver of two kinds (an
# object whose own fetch takes the keywords, and a Hash, whose fetch takes
# them as one Hash key): the dispatch default's builtin fetch arm read the
# keyword Hash from a temp it never declared. Pundit's Context#cached_find.
class Store
  def fetch(user:, record:)
    yield
  end
end

class Ctx
  def initialize(store)
    @store = store
  end

  def find(record)
    @store.fetch(user: "u", record: record) { "from the block" }
  end
end

p Ctx.new(Store.new).find(1)
p Ctx.new({}).find(1)
