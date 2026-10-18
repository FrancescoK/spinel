# The same lookup order for a method the program defines: a def in a
# superclass or in a module included before Enumerable is behind Enumerable;
# one in the class itself, or in a module included after Enumerable, is in
# front of it.
class Base
  def first; 42; end
  def count; 43; end
end

class Kid < Base
  include Enumerable
  def each; yield 5; yield 6; end
  def inn; [first, count]; end
end

class Own < Base
  include Enumerable
  def count; 99; end
  def each; yield 5; yield 6; end
end

class Quiet < Base
  def each; yield 5; yield 6; end
end

module HasCount
  def count; 77; end
end

class Early
  include HasCount
  include Enumerable
  def each; yield 5; yield 6; end
end

class Late
  include Enumerable
  include HasCount
  def each; yield 5; yield 6; end
end

class Together
  include HasCount, Enumerable
  def each; yield 5; yield 6; end
end

class Apart
  include Enumerable, HasCount
  def each; yield 5; yield 6; end
end

class Reopened
  include HasCount
  def each; yield 5; yield 6; end
end

class Reopened
  include Enumerable
end

module Nested
  include HasCount
  include Enumerable
end

class Wrapper
  include Nested
  def each; yield 5; yield 6; end
end

class Twice < Late
  include Enumerable
end

# #each itself is not Enumerable's: a superclass's serves a subclass that includes it
class EachBase
  def each; yield 1; yield 2; end
end

class EachKid < EachBase
  include Enumerable
end

p [Kid.new.first, Kid.new.count, Kid.new.inn]
p Own.new.count
p [Quiet.new.first, Quiet.new.count]
p Early.new.count
p Late.new.count
p Together.new.count
p Apart.new.count
p Reopened.new.count
p Wrapper.new.count
p Twice.new.count
p EachKid.new.map { |x| x * 2 }
p EachKid.new.count
