# A core module's method whose `self.class.new` block holds a `def self.hi`,
# the module both included and extended. The class run raises
# NotImplementedError where it is reached, and the `def self.hi` it would
# emit is refused at compile time, as it is where the call is emitted: the
# def's receiver is no object the compile can trace.
class Y; def initialize; yield if block_given?; end; end
module Enumerable
  def mk = self.class.new { def self.hi = :shi }
end
class Y; include Enumerable; extend Enumerable; def each = nil; def self.each = nil; end
if [1].size > 5
  k = Y.mk
  p k.class
end
p((Y.new.hi rescue :nohi))
p Y.respond_to?(:hi)
