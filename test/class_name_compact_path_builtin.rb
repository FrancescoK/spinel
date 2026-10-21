# A class or module defined under a builtin through a compact header
# (`module Comparable::Ext`) is named with the builtin's path, as CRuby
# names it: Class#name, #to_s, #inspect, an instance's inspect and a
# NoMethodError's message all said "Ext::Group::Passive" for
# "Comparable::Ext::Group::Passive". So did a class whose leaf another
# module shares (Group and Passive below), and a class defined through a
# path under a module whose leaf collided (`class Right::Box::Only` beside
# `Left::Box`), which was named by its leaf alone.

module Comparable::Ext
  module Group
    class Passive; end
  end
  class Failure < StandardError; end
end
module Comparable::Ext::Group
  class Capture; end
end
class Comparable::Ext::Group::Named < Comparable::Ext::Group::Capture; end
class Integer::Box; end
module Kernel::Table
  module Group
    class Passive; end
  end
end

p Comparable::Ext::Group::Passive.name
p Comparable::Ext::Group::Passive
p Comparable::Ext::Group.to_s
p Comparable::Ext.name
p Comparable::Ext::Group::Capture, Comparable::Ext::Group::Named
p Comparable::Ext::Group::Named.superclass
p Comparable::Ext::Group::Named.ancestors.take(2)
p Integer::Box.name
p Kernel::Table::Group::Passive.name
puts "in #{Comparable::Ext::Group::Passive}"

o = Comparable::Ext::Group::Passive.new
p o.class.name
puts o.inspect.sub(/0x\h+/, "X")
begin
  o.missing
rescue NoMethodError => e
  puts e.message
end
begin
  raise Comparable::Ext::Failure, "boom"
rescue => e
  p e.class, e
end

# the third segment of the name picks a constant of another module
p Kernel::Table.const_get(Comparable::Ext::Group::Named.name.split("::")[2])

module Left
  module Box; end
end
module Right
  module Box; end
end
class Left::Box::Item; end
class Right::Box::Item; end
class Right::Box::Only; end
p Right::Box::Only, Left::Box::Item.name
p Left::Box.constants.sort, Right::Box.constants.sort

# a `__` the program writes in a leaf is part of the name
module Comparable::Ext__Group
  class Leaf; end
end
p Comparable::Ext__Group, Comparable::Ext__Group::Leaf.name
module Right
  module Box__Alt
    class Leaf; end
  end
end
module Left
  module Box__Alt; end
end
module Right::Box__Alt::Deep
  class Leaf; end
end
p Right::Box__Alt::Leaf, Right::Box__Alt::Deep::Leaf
