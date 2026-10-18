# A class-body macro with a keyword parameter, whose name another class's
# attr_reader also spells. The zero-argument `r.attribute` cannot take the
# macro's two required positionals, and the keyword does not relax that, so
# the macro expands, with or without a keyword at the call site.
module Macros
  def attribute(name, type, default: nil) = define_method(name) { name.to_s }
end
class Rule
  attr_reader :attribute
  def initialize(a) = @attribute = a
end
class Todo
  extend Macros
  attribute :title, :string
  attribute :body, :text, default: 1
end
rules = [Rule.new("x")]
rules.each { |r| p r.attribute }
t = Todo.new
p t.title
p t.body
