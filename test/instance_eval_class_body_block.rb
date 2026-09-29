# A literal block in a class body, handed through class methods to an
# instance_eval constructor, calls the receiver's methods for their value

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
class Machine
  include Helpers
  attr_reader :log
  def initialize(owner, *args, &)
    @log = [owner]
    instance_eval(&) if block_given?
  end
  def before(opts) = @log << opts
  def self.find_or_create(owner, *args, &) = new(owner, *args, &)
end
module Macro
  def sm(*, &) = Machine.find_or_create(self, *, &)
end
class Class
  include Macro
end
class Vehicle
  M = sm(:state) do
    before parked: any - :parked
  end
end
p Vehicle::M.log
