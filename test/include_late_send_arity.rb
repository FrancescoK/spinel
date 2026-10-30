# A late include's method reached through a send with a computed name, as
# Active Support's deprecation proxies `@instance.__send__(@method)` reach
# Deprecation's Behavior methods: the guard entry keeps the method's own
# arity, so a send's arm passes the method's arguments as it would to the
# method (the hidden method behind it takes the same parameters).
module Behavior
  def behavior = @behavior ||= [:stderr]
  def tagged(t, sep = ":") = "#{t}#{sep}#{behavior.first}"
end
class Dep
  def initialize = @behavior = nil
end
class Other
  def behavior = [:other]
  def tagged(t, sep = ":") = "other#{sep}#{t}"
end
def ask(o, m, *a) = o.__send__(m, *a)
d0 = Dep.new
begin
  p ask(d0, :behavior)
rescue NoMethodError
  puts "no behavior yet"
end
class Dep
  include Behavior
end
[Dep.new, Other.new].each do |o|
  p ask(o, :behavior), ask(o, :tagged, "x"), ask(o, :tagged, "y", "/")
end
