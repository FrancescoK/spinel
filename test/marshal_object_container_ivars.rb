# A user object whose ivars hold typed Arrays and Hashes round-trips through
# Marshal, the containers coming back with their elements.
class Item
  attr_reader :name
  def initialize(name) = @name = name
end

class K
  attr_accessor :n
  attr_reader :ints, :floats, :strs, :mixed, :opts, :tags, :items, :none
  def initialize
    @n = 0
    @ints = [1, 2, 3]
    @floats = [1.5, 2.5]
    @strs = ["a", "b"]
    @mixed = [1, "x", :y, nil]
    @opts = {"size" => 3, "name" => "k"}
    @tags = {red: 1, blue: "two"}
    @items = [Item.new("i1"), Item.new("i2")]
    @none = nil
    @none = [4] if @n > 0
  end
end

k = K.new
k.n = 3
k.ints << 4
k2 = Marshal.load(Marshal.dump(k))
p k2.n
p k2.ints, k2.floats, k2.strs, k2.mixed
p k2.opts, k2.tags
p k2.items.map(&:name)
p k2.none
k2.ints << 5
p k2.ints.sum, k.ints.sum
