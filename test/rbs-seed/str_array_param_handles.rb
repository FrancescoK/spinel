# spinel: rbs-seed-run
# A parameter seeded Array[String] handed an Array whose String was changed
# in place: the caller's Array holds that String as its handle, and the
# conversion into the typed Array read the handle's pointer as bytes.
class SeedKeysSelector
  def initialize(keys)
    @keys = keys
  end

  def keys = @keys
end

keys = []
key = +"a"
key << "!"
keys << key
keys << "b"
p SeedKeysSelector.new(keys).keys
p SeedKeysSelector.new([]).keys
