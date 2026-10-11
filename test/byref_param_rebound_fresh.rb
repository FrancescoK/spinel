# A String parameter the method rebinds to a fresh String before mutating it
# is the method's own String: the caller's stays as it was, so nothing needs
# to be lent. Lent anyway, the rebind put the parameter on the shared handle,
# a caller passing its own parameter on took the handle too, and that
# caller's `text = other(text)` was refused as a mutated parameter. A
# constructor handing such a parameter on, through a writer that takes a
# String or another object, appends to nothing either. The probes after those
# keep the caller's String lent where the mutation can reach it: an append
# ahead of the rebind, a rebind only one branch runs, a block rebinding to an
# alias of the caller's String, an append inside the rebinding statement.
module Strip
  def strip_stars(text)
    return text unless text =~ %r%/\*.*\*/%m
    text = text.gsub(/Document-method:/, '')
    text.sub!(%r%/\*+%) { ' ' * $&.length }
    text.sub!(%r%\*+/%) { ' ' * $&.length }
    text
  end

  def strip_hashes(text) = text

  def normalize(text, c)
    return text if text.empty?
    text = c ? strip_stars(text) : strip_hashes(text)
    text = strip_hashes text
    text
  end
end
class CParser; include Strip; end
class RubyParser; include Strip; end

t = +"/* b */"
[CParser.new, RubyParser.new].each { |o| p o.normalize(t, true), o.normalize(t, false) }
p t

class Note
  def initialize(t) = @t = t
  def to_s = @t
end
class CodeObject
  include Strip
  def initialize = @comment = ''
  def comment=(comment)
    @comment = Note === comment ? comment.to_s : normalize(comment, true)
  end
  attr_reader :comment
end
class Mixin < CodeObject
  def initialize(name, comment)
    super()
    @name = name
    self.comment = comment
  end
end
class Extend < Mixin; end
class Include < Mixin; end
def add(k, name, comment) = k == Extend ? Extend.new(name, comment) : Include.new(name, comment)
p add(Extend, "x", t).comment, add(Include, "y", t).comment, t
o = CodeObject.new
o.comment = Note.new("n")
p o.comment

def ahead(io)
  io << "a"
  io = String.new("z")
  io << "b"
  io
end
s = +""
p ahead(s), s

def branch(t, f)
  t = t.dup if f
  t << "x"
  t
end
s = +"a"
p branch(s, false), branch(s, true), s

def aliased(t)
  orig = t
  t = t.dup
  [1].each { t = orig }
  t << "x"
  t
end
s = +"a"
p aliased(s), s

def inside(t)
  t = (t << "x").dup
  t << "y"
  t
end
s = +"a"
p inside(s), s
