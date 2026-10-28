# A class body in a lambda or a Proc runs when the program calls it, at no
# point of the load phase; it is a body of its class all the same, and the
# visibility words and mixins in it reach the class.
module Private
  class G
    def foo = "foo"
  end
  class K
    def bar = "bar"
  end
end
g = ::Private::G.new
l = -> {
  2.times do
    module ::Private
      class G
        private :foo
      end
    end
  end
}
l.call
begin
  p g.foo
rescue NoMethodError
  puts "NoMethodError foo"
end

m = -> {
  module Private
    class K
      private :bar
    end
  end
  nil
}
m.call
begin
  p Private::K.new.bar
rescue NoMethodError
  puts "NoMethodError bar"
end

class H
  def baz = "baz"
end
pr = Proc.new do
  class H
    private :baz
  end
  nil
end
pr.call
begin
  p H.new.baz
rescue NoMethodError
  puts "NoMethodError baz"
end

module Loud
  def t = "loud " + super
end
class T
  def t = "t"
end
lt = -> {
  class T
    prepend Loud
  end
  nil
}
lt.call
p T.new.t
p T.ancestors.take(2), T.include?(Loud), T.new.is_a?(Loud)

module Greet
  def hi = "hi"
end
class U
end
pu = Proc.new do
  class U
    include Greet
  end
  nil
end
pu.call
p U.new.hi, U.ancestors.take(2), U.include?(Greet), U.new.is_a?(Greet), [U.new, 1][0].is_a?(Greet)
