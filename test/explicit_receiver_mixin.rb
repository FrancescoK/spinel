# `K.prepend(M)`, `K.include(M)` and `K.attr_*(:x)` as statements: the
# reopening each amounts to (a file that prepends a module onto
# TTY::Prompt::List from its top level). The prepended module calls a
# private method of the class and reaches the original through super.
module TTY
  class Prompt
    class List
      def initialize(choices) = @choices = choices
      def keypress(c) = "list #{c}"
      def answer = @choices.first

      private

      def filterable? = false
    end
  end
end

module Motion
  def keypress(c)
    return super if filterable?
    c == "j" ? "down" : super
  end

  def answer
    @cancelled ? nil : super
  end

  def cancel = @cancelled = true
end

module Greeting
  def greet = "hi from #{self.class}"
end

module Shape
  def corners = 0
end

TTY::Prompt::List.prepend(Motion)
TTY::Prompt::List.include(Greeting)
TTY::Prompt::List.attr_reader :choices

l = TTY::Prompt::List.new(%w[a b])
p l.keypress("j"), l.keypress("x"), l.answer
l.cancel
p l.answer, l.greet, l.choices
p TTY::Prompt::List.ancestors.take(3)

class Square
  Square.include(Shape)
end
p Square.new.corners
