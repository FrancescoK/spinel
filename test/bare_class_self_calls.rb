module Lineage
  def parent = superclass
  def chain = ancestors.take(2)
end

class Base
  extend Lineage
  def self.label = to_s + "/" + inspect
  def self.comparable = include?(Comparable)
  def self.locked = frozen?
end

class Leaf < Base
  include Comparable
end

class Class
  def root_ward = superclass
end

p Leaf.parent
p Leaf.chain
p Leaf.label
p Base.comparable
p Leaf.comparable
p Leaf.locked
p Leaf.root_ward
