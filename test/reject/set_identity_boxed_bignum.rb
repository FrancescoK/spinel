# spinel: reject-subclass: enters or is looked up in a Set, in a program that calls Set#compare_by_identity
# A boxed value that may be a Bignum, read out of an Item it was stored in,
# enters an identity Set: CRuby makes an object of each Bignum, which an
# Integer held by value here is not, so the identity Set would find it
# otherwise than CRuby's. Refused at compile time.
require "set"

class Item
  attr_reader :value
  def initialize(value) = @value = value
end

seen = Set.new.compare_by_identity
[Item.new(Item.new(nil)), Item.new(2**64)].each { |it| seen << it.value }
p seen.size, seen.include?(2**64)
