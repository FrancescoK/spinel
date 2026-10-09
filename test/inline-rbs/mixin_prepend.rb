# As mixin_include.rb, mixed in with `prepend`: the copy sits in front of the
# class's own method and reaches it through super.
module Loud
  #: (String) -> String
  def t(n) = super(n) * 2
end

class Counter
  prepend Loud
  def t(n) = n + 1
end

p Counter.new.t(20)
