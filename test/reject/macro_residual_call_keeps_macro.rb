# spinel: reject-define-method-name
# `timestamps` expands everywhere and goes, but `attribute` is a name two
# modules define, so its expansion leaves `attribute :created_at, :datetime`
# as written, in Todo's body. That call runs at run time: Macros#attribute
# stays, and its computed define_method is refused. CRuby prints "rule",
# "created_at" and true.
module Macros
  def attribute(name, type) = define_method(name) { name.to_s }

  def timestamps
    attribute :created_at, :datetime
    define_method(:stamped) { true }
  end
end
module Other
  def attribute(name, type) = define_method(name) { "other #{name}" }
end
class Rule
  def attribute = "rule"
end
class Todo
  extend Macros
  timestamps
end
class Note
  extend Other
end
def show(r) = p(r.attribute)
show(Rule.new)
t = Todo.new
p t.created_at
p t.stamped
