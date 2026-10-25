# A class-body macro that another macro calls, whose name another class's
# attr_reader also spells. `timestamps` expands everywhere and goes, so the
# `attribute` calls in its body never run: they keep nothing of `attribute`
# alive, and its computed define_method goes too. `r.attribute`, a call on a
# receiver known only at run time, takes no argument where the macro takes two.
module Macros
  def attribute(name, type) = define_method(name) { name.to_s }

  def timestamps
    attribute :created_at, :datetime
    attribute :updated_at, :datetime
  end
end
class Rule
  attr_reader :attribute
  def initialize(a) = @attribute = a
end
class Todo
  extend Macros
  attribute :title, :string
  timestamps
end
def show(r) = p(r.attribute)
show(Rule.new("x"))
t = Todo.new
p t.title
p t.created_at
p t.updated_at
