# `singleton_class.attr_accessor :x` (and attr_reader / attr_writer) in a
# class or module body, statically: accessors on the class object over its
# class-level ivar -- what `def self.x; @x; end` / `def self.x=(v); @x = v;
# end` spell. Object#singleton_class as a VALUE stays unsupported (docs/
# limitations.md); this is the one idiom that never needs the object.
class Reporter
  def initialize(tag) = @tag = tag
  def tag = @tag
end
module Support
  @error_reporter = Reporter.new("errors")
  singleton_class.attr_accessor :error_reporter
  @event_reporter = Reporter.new("events")
  singleton_class.attr_reader :event_reporter
  singleton_class.attr_writer :level
  def self.level = @level
  def self.report(kind) = "#{error_reporter.tag}/#{kind}"
end
p Support.error_reporter.tag, Support.event_reporter.tag, Support.report("boom")
Support.error_reporter = Reporter.new("custom")
Support.level = 3
p Support.error_reporter.tag, Support.level
class Config
  @title, @limit = "cfg", 10
  singleton_class.attr_accessor :title, :limit
  def describe = "#{self.class.title}:#{self.class.limit}"
end
Config.limit += 5
p Config.title, Config.limit, Config.new.describe
p Support.respond_to?(:error_reporter=), Support.respond_to?(:event_reporter=), Config.respond_to?(:limit=)
module Registry
  @entries = []
  singleton_class.attr_accessor :entries
end
Registry.entries += ["a"]
Registry.entries += ["b"]
p Registry.entries
