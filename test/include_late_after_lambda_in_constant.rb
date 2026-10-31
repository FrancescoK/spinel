# A class whose first body is empty, reopened to include a module, with
# nothing run between the two bodies, after a lambda kept in an earlier
# constant calls the module's method on a value of unknown class. The
# refusal rule counts a call in a top-level statement's lambda as one that
# may run ahead of the include, so the include is guarded wherever the rule
# would ask, not only where code runs between the bodies. A program split
# around an autoloaded file has this shape: Active Support's
# Deprecation::DEFAULT_BEHAVIORS lambda calls `deprecator.debug`, and
# EventReporter::LogSubscriber includes ColorizeLogging in a reopening.
BEHAVIORS = {
  stderr: ->(target) { target.debug ? "debug on" : "debug off" }
}.freeze
class Quiet
  def debug = false
end
module Colorize
  def debug = true
end
class Sub
end
class Sub
  include Colorize
end
p BEHAVIORS[:stderr].call(Quiet.new), BEHAVIORS[:stderr].call(Sub.new)
