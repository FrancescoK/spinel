# An empty `{}` local passed to a parameter --rbs declares a Symbol-keyed
# Hash takes the Hash the declaration names: the literal has no key or value
# to go by. It was built as the String-keyed default, and the seed check
# refused the call as a contradiction (#10656). A local that a String key is
# stored into is still refused, which the seed check's own fixtures hold.
module EmptyHashSeedMaker
  EXTENSIONS = { flag: { "flag" => "as:flag" } }.freeze

  def self.serialized(extensions_map)
    extensions_map.size
  end
end

local = {}
p EmptyHashSeedMaker.serialized(local) + EmptyHashSeedMaker.serialized(EmptyHashSeedMaker::EXTENSIONS)
