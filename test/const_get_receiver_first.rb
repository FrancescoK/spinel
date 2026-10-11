# R.const_get(:N) looks in R before its superclasses and takes whatever R
# holds under N, a value or a nested class, even when another module holds
# a constant or class of the same leaf.

class Parent
  Item = "parent value"
  class Tool
    def self.who = "parent tool"
  end
  Mode = "parent mode"
end

class Child < Parent
  class Item
    def self.who = "child class"
  end
  Mode = "child mode"
end

class Grand < Child
end

Tool = 5

p Child.const_get(:Item)
p Child.const_get(:Item).who
p Grand.const_get(:Item)
p Parent.const_get(:Item)
p Child.const_get(:Tool)
p Child.const_get(:Tool).who
p Child.const_get(:Mode)
p Grand.const_get(:Mode)
p Parent.const_get(:Mode)
p Object.const_get(:Tool)

begin
  Child.const_get(:Tool, false)
rescue NameError => e
  puts "NameError: #{e.message}"
end
p Child.const_defined?(:Tool)
p Child.const_defined?(:Tool, false)

module Cfg
  Handler = "cfg value"
end
module Srv
  class Handler
    def self.who = "srv"
  end
end
Handler = 7

p Srv.const_get(:Handler, false)
p Srv.const_get(:Handler).who
p Srv.const_defined?(:Handler, false)
p Srv.const_defined?(:Handler)
p Cfg.const_get(:Handler, false)
p Cfg.const_defined?(:Handler, false)
p Object.const_get(:Handler)
