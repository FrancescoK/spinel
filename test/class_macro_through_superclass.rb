# A class-body macro a class reaches through its superclass: the
# superclass's own `def self.m`, or a module the superclass extends. The
# macro runs with the subclass as self (#8757).
class Base
  def self.attribute(name) = define_method(name) { name.to_s }
end
class Foo < Base
  attribute :title
end
class Bar < Foo
  attribute :body
end
p Foo.new.title
p Bar.new.title, Bar.new.body
p Foo.new.respond_to?(:body)

module Macros
  def field(name, val) = define_method(name) { val }
end
module App
  class Model
    extend Macros
  end
  class Post < Model
    field :kind, "post"
  end
end
p App::Post.new.kind
