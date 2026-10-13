# `self.class::NAME` (and `defined?` of it) in a module's method, on a class
# that has NAME from an included module, its own body, or nowhere: read
# through the class's ancestors, as CRuby looks it up.
module Fmt
  def valid?(x) = self.class::FORMATS.fetch(x, :none)
  def has_limit? = !defined?(self.class::LIMIT).nil?
end
module Limits
  LIMIT = 10
end
module Naming
  include Fmt
  include Limits
  FORMATS = { a: 1 }.freeze
end
class Cop
  include Naming
end
class StrictCop < Cop
  FORMATS = { b: 2 }.freeze
end
class Loose
  include Fmt
  FORMATS = { c: 3 }.freeze
end
p Cop.new.valid?(:a), StrictCop.new.valid?(:a), StrictCop.new.valid?(:b), Loose.new.valid?(:c)
p Cop.new.has_limit?, Loose.new.has_limit?
class Bare
  include Fmt
end
begin
  Bare.new.valid?(:a)
rescue NameError => e
  puts e.message
end

# An include resolves its module as Ruby does: B::Shared is not A::Shared,
# though both are "Shared".
module A
  module Shared
    TAG = 1
  end
end
module B
  module Shared
    def tagged? = !defined?(self.class::TAG).nil?
  end
end
class Tagless
  include B::Shared
end
p Tagless.new.tagged?

# A constant an included module keeps private is no class's to read.
module Hidden
  SECRET = 1
  private_constant :SECRET
end
module Peek
  def peek? = !defined?(self.class::SECRET).nil?
  def peek
    self.class::SECRET
  rescue NameError
    :hidden
  end
end
class Peeker
  include Hidden
  include Peek
end
p Peeker.new.peek?, Peeker.new.peek

# A superclass's constant reaches a subclass that includes the module.
module Reach
  def depth = self.class::DEPTH
  def depth? = !defined?(self.class::DEPTH).nil?
end
class Shallow
  DEPTH = 1
end
class Deep < Shallow
  include Reach
end
p Deep.new.depth, Deep.new.depth?

# The included module's constant, not one of the class's lexical scope.
module Unit
  SCALE = 10
end
module Scaled
  def scale = self.class::SCALE
end
module Outer
  SCALE = 2
  class Gauge
    include Unit
    include Scaled
  end
end
p Outer::Gauge.new.scale
