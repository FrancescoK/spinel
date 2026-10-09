# spinel: gc-minor
# A reader stored by its own method keeps the instance variable's String.
class ReaderPush
  attr_reader :text
  alias label text
  def initialize = (@text = +"n")
  def bare
    a = []
    a << text
    a[0] << "!"
    a
  end
  def explicit
    a = []
    a << self.text
    a[0] << "?"
    a
  end
  def variable
    a = []
    a << @text
    a[0] << "."
    a
  end
  def aliased
    a = []
    a << label
    a[0] << ":"
    a
  end
  def parens
    a = []
    a << (text)
    a[0] << "("
    a
  end
  def push
    a = []
    a.push(text)
    a[0] << ")"
    a
  end
end
r = ReaderPush.new
a = r.bare
p [r.text, a[0], r.text.equal?(a[0])]
a = r.explicit
p [r.text, a[0], r.text.equal?(a[0])]
a = r.variable
p [r.text, a[0], r.text.equal?(a[0])]
a = r.aliased
p [r.text, a[0], r.text.equal?(a[0])]
a = r.parens
p [r.text, a[0], r.text.equal?(a[0])]
a = r.push
p [r.text, a[0], r.text.equal?(a[0])]
