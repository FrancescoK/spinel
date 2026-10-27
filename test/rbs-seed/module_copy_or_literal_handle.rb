# `s || "lit"` in a module method copied into an including class, whose
# parameter a seeded `untyped` override hands on boxed and the copy takes
# as a String handle: the literal arm is a new handle, not the literal's
# bytes in the handle's slot (#10350).
def show_or_lit(h)
  p h
end

module LabeledOrLit
  def note(label = "")
    show_or_lit({ label: label || "n/d" })
  end
end

class WidgetOrLit
  include LabeledOrLit

  def note(label = nil)
    super(label)
  end
end

WidgetOrLit.new.note
WidgetOrLit.new.note("given")
