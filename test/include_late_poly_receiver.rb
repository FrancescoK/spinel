# A module a reopening includes after a method that calls its method on a
# receiver of unknown class: a call runs the module's method once the
# include has run, and what the class had until then, as in CRuby (its copy
# reads a flag the include's statement sets). No Wrapper exists before the
# include here, so every call reaches Tryable#try. Rails includes Tryable
# into Delegator at the end of core_ext/object/try.rb, after the logger's
# `logdev.try(:filename)` on a device of unknown class.
module Tryable
  def try(name) = respond_to?(name) ? public_send(name) : nil
end
class Dev
  include Tryable
  def filename = "dev.log"
end
class Wrapper
  def initialize(dev) = @dev = dev
  def dev = @dev
end
def sources(devs) = devs.filter_map { |d| d.try(:filename) || d.try(:dev) }
puts sources([Dev.new]).inspect
class Wrapper
  include Tryable
end
w = Wrapper.new(Dev.new)
puts sources([Dev.new, w]).map(&:class).inspect
