# A `class << Const` in another class's body runs its statements where it
# stands, as at the top level and as `class << self` does; its defs are
# Const's class methods.
module Ext; end

class Host
  puts "before"
  class << Ext
    puts "in Ext's singleton class"
    def helper = :helped
  end
  puts "after"
end

p Ext.helper
