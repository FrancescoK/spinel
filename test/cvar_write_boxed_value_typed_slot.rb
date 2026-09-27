# A class variable typed by its default (a Hash, a bool) written from a
# boxed value: a class-level writer nobody calls, on a class whose class
# methods are reached through a `self.class.x` dispatch (which boxes what it
# passes), so the writer's parameter is poly.
# The write assigned the box to the typed slot (a C type error), in the
# statement form and in the value form (`def self.x=(v); @@x = v; end`, whose
# value is the assignment). The box is unboxed into the slot.
class Store
  @@options = { expires: 60 }
  @@quiet = false
  def self.options = @@options
  def self.options=(val)
    @@options = val
  end
  def self.quiet = @@quiet
  def self.quiet=(val)
    @@quiet = val
    :done
  end
  def options = self.class.options
  def quiet = self.class.quiet
end
class MemStore < Store; end
s = MemStore.new
p s.options, s.quiet
p Store.respond_to?(:options=), Store.respond_to?(:quiet=)
