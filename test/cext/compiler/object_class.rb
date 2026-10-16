# frozen_string_literal: true
require_relative 'object_class'

module ClassScope
  class Parent
    def self.name = "overridden name"
    def class = String
  end
  class Child < Parent; end
end
class ClassArray < Array; end
class ClassHash < Hash; end

parent = ClassScope::Parent.new
child = ClassScope::Child.new
singleton = Object.new
def singleton.singleton_marker = 1
p CextObjectClass.of(singleton) == Object

p CextObjectClass.of(parent) == ClassScope::Parent
p CextObjectClass.of(child) == ClassScope::Child
p parent.class == String
p CextObjectClass.name_of(ClassScope::Parent)
p ClassScope::Parent.name
p CextObjectClass.name_of(ClassScope)
p CextObjectClass.name_of(ClassScope::Parent.singleton_class)
p CextObjectClass.name_of(ClassScope.singleton_class)
p CextObjectClass.of(ClassArray.new) == ClassArray
p CextObjectClass.of(ClassHash.new) == ClassHash

[nil, true, false, 7, 1.5, :symbol, "text", [1], {"a" => 2}, Object, ClassScope].each do |value|
  p CextObjectClass.name_of(CextObjectClass.of(value))
end
