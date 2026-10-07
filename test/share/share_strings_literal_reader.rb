# Flag-only: a literal container keeps its reader's shared String when
# splatted or passed whole. Frozen and binary Strings keep
# their identity and marks; a mutable String is changed through either name.
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
  end
end

LiteralReader.new.run
