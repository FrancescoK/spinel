# A class nested in a module under a builtin's name (graphql's
# MonitorTrace::Monitor) is a new constant in CRuby: inside its module the
# name means the nested class, and everywhere else Monitor and OpenStruct stay
# the builtins.
require "monitor"
require "ostruct"
class Outer; end
class Outer::Monitor
  def initialize(n) = @n = n
  def n = @n
end
module G
  module T
    module MonitorTrace
      class Monitor
        def self.build = new
        def trace = :traced
      end
      def self.mk = Monitor.build.trace
      def self.real = ::Monitor.new.synchronize { :inner_sync }
    end
  end
end
module A
  Monitor = Struct.new(:x)
  class OpenStruct
    def initialize = @v = 5
    def v = @v
  end
  def self.inside = [Monitor.new(7).x, OpenStruct.new.v]
end
p Outer::Monitor.new(3).n
p G::T::MonitorTrace.mk, G::T::MonitorTrace.real
p A.inside
p A::Monitor.new(1), A::OpenStruct.new.v, A::OpenStruct.name
p Math.sqrt(4.0), Math::E.round(3)
os = OpenStruct.new(a: 1)
p os.a
m = Monitor.new
p m.synchronize { 42 }
class Outer::Monitor
  def extra = :reopened
end
p Outer::Monitor.new(0).extra
