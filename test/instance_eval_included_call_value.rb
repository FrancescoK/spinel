# A bare call in a block run by instance_eval answers the receiver's
# method's value, an aliased one from an included module too

class Matcher
  def -(other) = [:except, other]
end
class AllMatcher < Matcher
  def self.instance = INSTANCE
  INSTANCE = new
end
module Helpers
  def all = AllMatcher.instance
  alias any all
end
class M
  include Helpers
  attr_reader :log
  def initialize(&)
    @log = []
    instance_eval(&) if block_given?
  end
  def before(opts) = @log << opts
  def self.build(&) = new(&)
end
p M.new { before parked: any - :x }.log
p [M, nil].first.build { before parked: any - :parked }.log
blk = proc { before parked: any - :idle }
p M.build(&blk).log
