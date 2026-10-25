# spinel: reject-define-method-name
# Nothing expands `attribute`, and the only call of it takes one argument
# where the macro takes two, but Todo's own `attribute` reaches the macro
# through super with two: the macro stays, and its computed define_method is
# refused. CRuby prints "title".
module Macros
  def attribute(name, type) = define_method(name) { name.to_s }
end
class Todo
  extend Macros
  def self.attribute(name) = super(name, :string)
  attribute :title
end
p Todo.new.title
