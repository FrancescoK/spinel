# Flag-only: a literal container keeps its reader's shared String when
# splatted or passed whole to a user method, and a rest parameter keeps
# each reader argument it gathers. Frozen and binary Strings keep
# their identity and marks; a mutable String is changed through either name.
# A literal handed to a builtin (`p [a, b]`) or a block's value still builds.
class LiteralReader
  attr_accessor :text
  def first(*items) = items[0]
  def value(items) = items[0]
  def keyword(k:) = k

  def run
    self.text = "aabc"
    t = first(*[self.text])
    p self.text.equal?(t), t.frozen?
    begin
      t.concat("y")
    rescue => e
      p e.class
    end
    p self.text.equal?(t), [self.text, t]

    self.text = +"a\0b"
    u = value([self.text])
    u << "c"
    p self.text.equal?(u), [self.text, u]

    self.text = "c\0d"
    v = keyword(**{ k: self.text })
    p self.text.equal?(v), v.frozen?
    begin
      v.prepend("x")
    rescue => e
      p e.class
    end
    p [self.text, v]

    self.text = +"r"
    w = first(self.text)
    w << "s"
    p self.text.equal?(w), [self.text, w]
  end
end

def first_top(*items) = items[0]
def pair_top(a, b) = yield(a, b)

r = LiteralReader.new
r.run
r.text = +"x"
y = first_top(*[r.text])
y << "y"
p r.text.equal?(y), r.text
z = first_top(r.text, 1)
z << "z"
p r.text.equal?(z), r.text
a = r.text
p [r.text, a]
p pair_top(r.text, a) { |m, n| [m, n] }
