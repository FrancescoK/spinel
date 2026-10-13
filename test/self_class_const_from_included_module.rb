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
