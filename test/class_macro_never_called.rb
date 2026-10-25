# A macro module a class extends but never calls, whose macro's name another
# class's reader also spells. No call of `attribute` can take its two
# arguments, so the macro, with its computed define_method, goes.
module Macros
  def attribute(name, type) = define_method(name) { name.to_s }
end
class Rule
  def initialize(a) = @a = a
  def attribute = @a
end
class Todo
  extend Macros
  def initialize = @title = "t"
  attr_reader :title
end
def show(r) = p(r.attribute)
show(Rule.new("x"))
p Todo.new.title
