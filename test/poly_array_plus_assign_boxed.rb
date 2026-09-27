class Index
  def initialize = (@by = { name: { a: 1, b: 2 }, id: { 7 => 1 } })
  def keys(on = :name) = @by[on].keys
  def names
    order = [:x, "y"]
    order += keys(:name)
    order += keys(:id)
    order
  end
  def bad(v)
    order = [:x, "y"]
    order += v
    order
  rescue TypeError => e
    e.message
  end
end

idx = Index.new
p idx.names
p idx.bad([1, :z].first)
p idx.bad([[3], 1].first)
