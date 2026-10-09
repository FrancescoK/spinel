# Class.new(Hash) with a block becomes `class Registry < Hash`, whose
# instances are Hashes with the class's methods.
Registry = Class.new(Hash) do
  def first_key = keys.first
end
p Registry.new.first_key
