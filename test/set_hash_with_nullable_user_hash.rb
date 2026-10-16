# Set#hash XORs its elements' hashes. Beside a class whose #hash may answer
# nil, it still compiles and answers an Integer that equal sets share.
require "set"

class Tag
  def initialize(name) = @name = name
  def hash = @name&.size
end

p Set[1, "a", :b].hash.is_a?(Integer)
p Set[1, "a", :b].hash == Set[:b, "a", 1].hash
p Tag.new("x").hash
