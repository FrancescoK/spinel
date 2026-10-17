# A class-body macro whose name another class's attr_reader also spells. The
# reader is an instance method of an unrelated class, and `r.attribute` takes
# no argument where the macro takes one: neither keeps the macro, so
# `attribute :title` expands and the macro's computed define_method goes.
module Macros
  def attribute(name) = define_method(name) { name.to_s }
end
class Rule
  attr_reader :attribute
  def initialize(a) = @attribute = a
end
class Todo
  extend Macros
  attribute :title
  def show = title
end
rules = [Rule.new("x")]
rules.each { |r| p r.attribute }
p Todo.new.public_send("show".to_sym)
