# const_get / const_defined? with a name known only at run time, on a
# module whose leaf name another class shares (Shop::Item, defined first,
# with constants of its own). The table of the module's constants was built
# from, and placed in, the first body of that leaf: Store::Item's table went
# into Shop::Item and named Shop::Item's constants.

module Shop
  class Item
    KINDS = %i[a b].freeze
    def kinds = KINDS
  end
end

module Store
  module Item
    Hat = :hat
    class Coat; end
  end
end
module Store::Item
  module Shoe; end
end
class Store::Item::Bag; end

module Store
  def self.find(n) = Item.const_get(n)
  def self.has?(n) = Item.const_defined?(n)
end

names = %w[Hat Coat Shoe Bag KINDS].map { |s| s + "" }
names.each { |n| p [n, Store::Item.const_defined?(n), Store.has?(n)] }
p Store.find(names[0]), Store::Item.const_get(names[1]), Store::Item.const_get(names[3])
p Shop::Item.const_defined?(names[4]), Shop::Item.const_get(names[4])
p Shop::Item.const_defined?(names[0])
begin
  Store::Item.const_get(names[4])
rescue NameError => e
  p e.message
end
p Shop::Item.new.kinds

# the other order: the module first, a class of its leaf after it. The
# table of the module held the class's constant too, and answered true.
module Store
  module Tag
    Red = :red
  end
end
module Shop
  class Tag
    SIZES = [1, 2].freeze
  end
end
tag_names = %w[Red SIZES].map { |s| s + "" }
p tag_names.map { |n| Store::Tag.const_defined?(n) }
p tag_names.map { |n| Shop::Tag.const_defined?(n) }
p Store::Tag.const_get(tag_names[0])
