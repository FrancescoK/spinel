# `extend self` covers every method of the module, wherever its body was
# reopened: activesupport's Inflector is `extend self` in inflector/methods.rb,
# and its transliterate.rb -- loaded first -- reopens the module for
# parameterize and transliterate, which are still reached as
# `Inflector.parameterize(s)`. A later reopening counts the same way, and a
# same-named module elsewhere gets nothing.

module App
  module Inflector
    def parameterize(s, sep: "-") = s.downcase.tr(" ", sep)
  end
end

module App
  module Inflector
    extend self
    def underscore(s) = s.gsub("::", "/").downcase
  end
end

module App
  module Inflector
    def camelize(s) = s.split("_").map(&:capitalize).join
  end
end

class App::Inflector::Client
  include App::Inflector
  def run = [parameterize("Hello World"), underscore("Foo::Bar"), camelize("foo_bar")]
end

puts App::Inflector.parameterize("Hello World")
puts App::Inflector.parameterize("Hello World", sep: "_")
puts App::Inflector.underscore("Foo::Bar")
puts App::Inflector.camelize("foo_bar")
p App::Inflector::Client.new.run

# a sibling module in the same namespace is not covered: a twin of its
# instance method would shadow the module method it defines itself
module App
  module Tags
    def self.tag(s) = "<#{s}>"
    def tag(s) = "[#{s}]"
  end
  class Page
    include Tags
    def render = tag("p")
  end
end
puts App::Tags.tag("x")
puts App::Page.new.render

# an unrelated module of the same leaf name stays an instance-method mixin
module Other
  module Inflector
    def shout(s) = s.upcase + "!"
  end
  class Speaker
    include Inflector
  end
end
puts Other::Speaker.new.shout("hi")
