# A deliberately-unsupported feature (docs/limitations.md) names itself rather
# than dumping compiler internals. A user-defined method of the same name is
# that method, not the builtin, so it still works (#2652 / #2667 / #2668).
class Dsl
  def extend(x); "user-extend:#{x}"; end
  def ruby2_keywords; "user-r2k"; end
  def define_singleton_method(n); "user-dsm:#{n}"; end
  def refine(x); "user-refine:#{x}"; end
  def using(x); "user-using:#{x}"; end
  def include(x); "user-include:#{x}"; end
  def set_trace_func(x); "user-stf:#{x}"; end
end
d = Dsl.new
p d.extend(1)
p d.ruby2_keywords
p d.define_singleton_method(:z)
p d.refine(1)
p d.using(2)
p d.include(3)
p d.set_trace_func(4)
def extend(a); "toplevel:#{a}"; end
p extend(9)

# a user-defined SINGLETON method of a limited name is that method too:
# `Mod.prepend(kwargs)` resolves to `def self.prepend`, not Module#prepend (#2712)
module Broadcasts
  def self.prepend(stream:, target:, html:)
    "#{stream}/#{target}/#{html}"
  end
  def self.replace(x); "rep:#{x}"; end
end
puts Broadcasts.prepend(stream: "articles", target: "articles", html: "<div/>")
puts Broadcasts.replace(1)

# the compile-time forms these limits point you at keep working
module Mx; def mm; "mm"; end; end
class Ok; include Mx; attr_accessor :v; end
o = Ok.new
o.v = 7
p o.v
p o.mm
p Ok.new.is_a?(Mx)

# binding is NOT in the unsupported set: local_variable_get works
x = 42
p binding.local_variable_get(:x)

# a user-reopened Time.parse / Time.strptime / Time.iso8601 is that method, not the
# documented limit on the builtin's own (K-001)
class Time
  def self.parse(s); "user-parse:#{s}"; end
  def self.strptime(s, fmt); "user-strptime:#{s}/#{fmt}"; end
  def self.iso8601(s); "user-iso8601:#{s}"; end
end
p Time.parse("2024-01-01")
p Time.strptime("2024-01-01", "%Y-%m-%d")
p Time.iso8601("2024-01-01")
