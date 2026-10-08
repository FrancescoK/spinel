# A user object whose class defines == (here through Comparable's <=>) looked
# up in a typed Array: CRuby calls the method against every element, and the
# typed slot has no room for the object. Spinel refuses at compile time and
# names the case, rather than putting the raw pointer in the sp_int slot and
# stopping the generated-C build. An object whose class compares nothing
# simply misses -- pinned by test/typed_slot_conversion.rb.
# spinel: rbs-seed-check
class Near
  include Comparable
  def <=>(other)
    1 <=> other
  end
end
p [1, 2, 3].count(Near.new)
