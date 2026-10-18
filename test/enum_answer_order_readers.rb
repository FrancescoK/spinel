# A call named like an Enumerable method goes to whichever comes first in
# Ruby's lookup order: the program's attr_reader, or Enumerable's. A class's
# own reader, one of a module it includes, and one a superclass declares come
# before Enumerable only where nothing puts Enumerable ahead of them: a class
# that includes Enumerable itself has it in front of its superclass's reader,
# in front of the modules included before it and behind those included after.
module HasCount
  attr_reader :count
end

class Base
  attr_reader :first
  def initialize; @first = 42; end
end

class Kid < Base
  include Enumerable
  def initialize; super; @count = 9; end
  def each; yield 5; yield 6; end
  def inn; [first, self.first]; end
end

class Mixed
  include Enumerable
  include HasCount
  def initialize; @count = 77; end
  def each; yield 5; yield 6; end
  def inn; count; end
end

class EarlyMixed
  include HasCount
  include Enumerable
  def initialize; @count = 77; end
  def each; yield 5; yield 6; end
  def inn; count; end
end

class Plain
  include Enumerable
  def each; yield 1; yield 2; yield 3; end
end

class WriterOnly
  include Enumerable
  attr_writer :count, :first
  def each; yield 1; yield 2; end
end

class Defined
  include Enumerable
  define_method(:count) { 55 }
  def each; yield 1; yield 2; end
end

class Aliased
  include Enumerable
  attr_reader :sz
  alias_method :count, :sz
  alias first sz
  def initialize; @sz = 31; end
  def each; yield 1; yield 2; end
end

class Short
  include Enumerable
  attr :count, :min
  def initialize; @count = 4; @min = 99; end
  def each; yield 1; yield 2; end
end

class CountBase
  attr_reader :count
  def initialize; @count = 43; end
end

class CountKid < CountBase
  include Enumerable
  def each; yield 5; yield 6; end
  def inn; count; end
end

class CountPlainKid < CountBase
  def each; yield 5; yield 6; end
end

module Enumerating
  include Enumerable
end

class MinBase
  attr_reader :min
  def initialize; @min = 8; end
end

class MinKid < MinBase
  include Enumerating
  def each; yield 5; yield 6; end
end

class Both < Base
  include Enumerable
  attr_reader :first
  def initialize; @first = 7; end
  def each; yield 5; yield 6; end
end

# a prepended Enumerable is in front of the class itself
class Prepended
  prepend Enumerable
  attr_reader :count
  def initialize; @count = 9; end
  def each; yield 1; yield 2; end
end

k = Kid.new
p [k.first, k.count, k.inn]
m = Mixed.new
p [m.count, m.inn, m.first]
e = EarlyMixed.new
p [e.count, e.inn]
o = Plain.new
p [o.count, o.first, o.min]
w = WriterOnly.new
w.count = 3
p [w.count, w.first]
p Defined.new.count
a = Aliased.new
p [a.count, a.first]
t = Short.new
p [t.count, t.min, t.max]
ck = CountKid.new
p ck.count
p ck.inn
p CountPlainKid.new.count
p MinKid.new.min
p Both.new.first
p Prepended.new.count
