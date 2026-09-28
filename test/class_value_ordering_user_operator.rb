# A class that defines Module#< or <=> itself answers with its own method,
# also when the argument is not a class. The boxed class ordering beside it
# (a class read out of an Array or Hash) still uses the class graph.

class Foo
  def self.<(o) = o.is_a?(Integer) ? o > 3 : nil
  def self.<=>(o) = 42
end

class SubFoo < Foo
end

module Outer
  class Bar
    def self.>=(o) = o == :yes
  end
end

p(Foo < 5)
p(Foo < 1)
p(Foo < "x")
p(Foo <=> 5)
p(Foo <=> "x")
p(SubFoo < 9)
p(SubFoo <=> 0)
k = Foo
p(k < 7)
p(Outer::Bar >= :yes)
p(Outer::Bar >= :no)

class Base; end
class Sub < Base; end
class Other; end

p([Sub][0] < Base)
p(Base > [Sub][0])
p([Base][0] < Sub)
p([Other][0] < Base)
p([Sub][0] <=> Base)
p(Base <=> [Sub][0])
p([Other][0] <=> Base)
p({rb: Sub}[:rb] <= Sub)
p([Sub, Base].sort { |a, b| a <=> b })
begin
  p(Base < [1][0])
rescue TypeError => e
  p e.message
end
p(Base <=> [1][0])
