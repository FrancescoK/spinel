# A class << self reader holding an object, read bare in a class method,
# still dispatches to the object's class when respond_to? asks about the
# writer elsewhere (which leaves the slot a boxed value): the self the call
# was given there is the class method's, not main's.
class Reporter
  def initialize(tag) = @tag = tag
  def tag = @tag
end

module Support
  @r = Reporter.new("errors")
  class << self; attr_accessor :r; end
  def self.report = r.tag
  def self.explicit = self.r.tag
end
p Support.report, Support.explicit
p Support.respond_to?(:r=)

class Panel
  @r = Reporter.new("panel")
  class << self; attr_accessor :r; end
  def self.report = r.tag
end
Panel.r = Reporter.new("swapped")
p Panel.report, Panel.respond_to?(:r=)
