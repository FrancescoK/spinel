# `singleton_class.prepend M` puts M's methods in front of the class's own
# class methods: M's answers, and its super reaches the class's own. It was
# made an `extend M`, which goes behind them, so the class's own answered,
# and an alias in M of a name the class defines was refused
# (activesupport's core_ext/erb/util.rb on ERB::Util).

module Loud
  def greet(name) = super(name).upcase + "!"
end

class Greeter
  def self.greet(name) = "hello, #{name}"
  singleton_class.prepend Loud
end

p Greeter.greet("ann")

require "erb"

module Ext
  module ERBUtil
    def html_escape(s)
      s = s.to_s
      s.start_with?("!") ? s : super(s)
    end
    alias :unwrapped_html_escape :html_escape

    def html_escape(s)
      "[" + unwrapped_html_escape(s) + "]"
    end
    alias h html_escape
  end

  module ERBUtilPrivate
    include ERBUtil
    private :unwrapped_html_escape, :html_escape, :h
  end
end

class ERB
  module Util
    prepend Ext::ERBUtilPrivate
    singleton_class.prepend Ext::ERBUtil
  end
end

p ERB::Util.html_escape("<a>"), ERB::Util.h("!<b>"), ERB::Util.unwrapped_html_escape("<c>")
include ERB::Util
p h("<d>")
