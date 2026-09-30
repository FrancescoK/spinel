# Methods a `module Kernel` reopening adds are reachable as bare calls from
# every scope -- Kernel is mixed into Object -- and, under module_function,
# with the module as the receiver too. activesupport's
# core_ext/kernel/reporting.rb is the shape: silence_warnings { ... } from a
# module method. The reopening's defs are modelled as top-level defs.

module Kernel
  module_function

  def silence_warnings(&block)
    with_warnings(nil, &block)
  end

  def with_warnings(flag)
    old_verbose, $VERBOSE = $VERBOSE, flag
    yield
  ensure
    $VERBOSE = old_verbose
  end

  def suppress(*exception_classes)
    yield
  rescue *exception_classes
  end

  def twice(x) = x * 2
end

class Store
  def load = silence_warnings { "loaded" }
  def self.k = twice(5)
end

module Serializer
  def self.setup = suppress(ZeroDivisionError) { 1 / 0; :unreached }
  module_function
  def n = twice(4)
end

p Store.new.load, Store.k, Serializer.setup, Serializer.n
p silence_warnings { twice(7) }
p Kernel.twice(3)
p Kernel.silence_warnings { :k }
puts Kernel.format("%03d", 7)
