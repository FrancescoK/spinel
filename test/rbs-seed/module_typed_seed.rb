# A value seeded with a module type is any of its includers, boxed: its
# calls go to the includer's copy of the module's methods, and an includer
# stores into it (#7169).
module MtsTagged
  def label = "tag:#{name}"
end

class MtsItem
  include MtsTagged
  def name = "item"
end

class MtsBox
  def initialize(thing)
    @thing = thing
  end

  def thing
    @thing
  end
end

t = MtsBox.new(nil).thing
puts(t ? t.label : "none")
puts MtsBox.new(MtsItem.new).thing.label
puts MtsItem.new.label
