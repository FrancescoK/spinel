# A class-body macro that builds a name from the class's own name:
# `self.name`, `to_s` or `inspect` of the class the macro expands in.
module Macros
  def has_many(name)
    key = "#{self.name.downcase}_id"
    define_method(name) { key }
  end

  def tagged(name)
    tag = to_s.sub("::", "-")
    define_method(name) { tag }
  end
end

class Todo
  extend Macros
  has_many :comments
  tagged :tag
end

module Admin
  class Post
    extend Macros
    has_many :likes
    tagged :tag
  end
end

class Item
  def self.kind(name)
    str = self.name
    define_method(name) { str }
  end
  kind :type
end

class Base
  def self.label(name)
    str = self.name
    define_method(name) { str }
  end
end
class Sub < Base
  label :who
end
class Todo
  has_many :more
end
class Plain
  extend Macros
  tagged :t1
end
class Plain
  tagged :t2
  has_many :c2
end
module Insp
  def shown(name)
    str = self.inspect
    define_method(name) { str }
  end
end
class Shown
  extend Insp
  shown :i
end

p Todo.new.comments, Todo.new.tag
p Admin::Post.new.likes, Admin::Post.new.tag
p Item.new.type
p Sub.new.who, Todo.new.more
p Plain.new.t1, Plain.new.t2, Plain.new.c2
p Shown.new.i

# ordinary instance methods of these names elsewhere do not stop the expansion
class Labeled
  def to_s = "labeled"
  def inspect = "#<Labeled>"
  def name = "own"
end
class Plain
  def name = "plain-own"
end
p Labeled.new.to_s, Labeled.new.inspect, Labeled.new.name, Plain.new.name
