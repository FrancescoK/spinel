# Class.new(Hash) with a block becomes `class Registry < Hash` (#7075).
# spinel: reject-subclass: class Registry < Hash: subclassing Hash
Registry = Class.new(Hash) do
  def first_key = keys.first
end
p Registry.new.first_key
