# Macros nothing expands, whose names an unrelated reader also spells. The
# String "include" that is only printed mixes no module in, and the
# `public_send(:build, name)` in `setup` runs only when `setup` does, which
# nothing calls: both macros go, with their computed define_methods.
module Macros
  def attribute(name, type) = define_method(name) { name.to_s }
  def build(name) = define_method(name) { name.to_s }
  def setup(name) = public_send(:build, name)
end
class Rule
  def attribute = "rule"
  def build = "built"
end
class Todo
  extend Macros
end
def show(r) = p(r.attribute, r.build)
show(Rule.new)
puts "include"
