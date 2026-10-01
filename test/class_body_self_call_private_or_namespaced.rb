# A class body's call of its own class method keeps a call on self: a
# private class method answers it. And a class of the same leaf name in
# another namespace is another class, whose class methods the body's bare
# call does not reach (CRuby raises NameError there).
class Base
  def self.hidden = "hidden"
  private_class_method :hidden
  class << self
    private
    def secret = "secret"
  end
end
class Sub < Base
  p hidden
  p secret
end

module Outer
  class Foo
    def self.tag = "outer"
  end
end
module Other
  class Foo
  end
end
class Other::Foo
  begin
    tag
  rescue NameError => e
    puts e.class
  end
end
class Outer::Foo
  p tag
end
module Outer
  class Bar < Foo
    p tag
  end
end
