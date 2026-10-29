# A statically resolved constant path still reads each parent before its leaf.
class Target
  X = 7
end
module Outer
  def self.read
    p Outer::HOLDER::X
  rescue NameError => e
    puts e.message
  end
  def self.arguments
    puts 'arguments', Outer::HOLDER::X
  rescue NameError => e
    puts e.message
  end
end
Outer.read
Outer.arguments
module Outer
  HOLDER = (puts 'assigned'; Target)
end
Outer.read
Outer.arguments

module ModTarget
  Z = 8
end
module ModOuter
  def self.read
    p ModOuter::PARENT::Z
  rescue NameError => e
    puts e.message
  end
end
ModOuter.read
module ModOuter
  PARENT = (puts 'module assigned'; ModTarget)
end
ModOuter.read

module Two
  module Inner
    V = 9
  end
  def self.read
    p Two::LINK::Inner::V
  rescue NameError => e
    puts e.message
  end
end
Two.read
module Two
  LINK = (puts 'two assigned'; Two)
end
Two.read

module Top
end
begin
  p Top::LATE::X
rescue NameError => e
  puts e.message
end
module Top
  LATE = (puts 'top assigned'; Target)
end
p Top::LATE::X

def consume(first, item)
  puts 'consumed'
end
module FoldTarget
  class Child
    def initialize(xs)
      puts 'initialized'
    end
    def self.five = 5
  end
end
module FoldOuter
  def self.read
    p FoldOuter::METHOD_PARENT::Child.five
  rescue NameError => e
    puts e.message
  end
  def self.ordered
    consume([puts('earlier')], FoldOuter::METHOD_PARENT::Child.new([puts('argument')]))
  rescue NameError => e
    puts e.message
  end
end
FoldOuter.read
FoldOuter.ordered
module FoldOuter
  METHOD_PARENT = (puts 'fold assigned'; FoldTarget)
end
FoldOuter.read
FoldOuter.ordered

module QueryTarget
  class QueryChild
  end
end
module QueryOuter
  def self.kind(value)
    p value.is_a?(QueryOuter::QUERY_PARENT::QueryChild)
  rescue NameError => e
    puts e.message
  end
  def self.exact(value)
    p value.instance_of?(QueryOuter::QUERY_PARENT::QueryChild)
  rescue NameError => e
    puts e.message
  end
end
query = QueryTarget::QueryChild.new
QueryOuter.kind(query)
QueryOuter.kind(nil)
QueryOuter.exact(query)
module QueryOuter
  QUERY_PARENT = (puts 'query assigned'; QueryTarget)
end
QueryOuter.kind(query)
QueryOuter.kind(nil)
QueryOuter.exact(query)
