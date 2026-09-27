# super(&) into a yielding ancestor forwards the block, whether the method
# is spliced at a direct call or reached through a poly dispatch arm.
class Base
  def each_twice
    yield 1
    yield 2
  end
end
class Anon < Base
  def each_twice(&) = super(&)
end
class Bare < Base
  def each_twice(&) = super
end
class Named < Base
  def each_twice(&blk) = super(&blk)
end
class Deep < Anon
  def each_twice(&) = super(&)
end
class Other < Base
  def each_twice(&) = super(&PR)
end
class Leaf < Base
  def each_twice(&) = super(&)
end
PR = proc { |x| puts "PR #{x}" }

# direct receivers
Leaf.new.each_twice { |x| puts "leaf #{x}" }
Deep.new.each_twice { |x| puts "deep #{x}" }
Named.new.each_twice { |x| puts "named #{x}" }
Other.new.each_twice { |x| puts "ignored #{x}" }

# poly receivers
[Anon, Bare, Named, Deep].each do |k|
  k.new.each_twice { |x| puts "#{k} #{x * 10}" }
end

# a proc passed with & drives the splice
pr = proc { |x| puts "proc #{x}" }
Leaf.new.each_twice(&pr)
Named.new.each_twice(&pr)
[Deep, Bare].each { |k| k.new.each_twice(&pr) }

# the block writes the caller's locals
class Sum < Base
  def each_twice(&) = super(&)
end
acc = []
Sum.new.each_twice { |x| acc << x * 100 }
p acc
