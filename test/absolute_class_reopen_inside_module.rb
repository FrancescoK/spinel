# `class ::Array` written inside a module reopens the top-level Array (and
# `class ::Widget` the top-level Widget) -- the leading `::` names the root,
# whatever module the definition sits in.
module Fmt
  def label = "fmt:#{size}"
end

module Outer
  class ::Array
    prepend Fmt
    def hi = "hi#{size}"
  end

  class ::Widget
    def w = :w
  end

  class Inner
    def where = Module.nesting.inspect
  end
end

p [1, 2].hi, [1, 2].label, Widget.new.w, Outer::Inner.new.class.name
