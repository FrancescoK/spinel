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
  def append_rest(*items) = items.each { |e| e << "!" }
  def append_tail(a, *items) = items.each { |e| e << "!" }
  def append_keyword(a, *items, suffix:) = items.each { |e| e << suffix }
  def append_post(*items, last) = (items.each { |e| e << "!" }; last << "?")

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

    # A plain reader before a splat is a rest element too. The leading
    # positional stays outside the rest, and trailing keywords bind by name.
    self.text = +"a"
    items = [+"b"]
    append_rest(self.text, *items)
    p self.text, items

    self.text = +"c"
    lead = +"lead"
    tail = [+"d"]
    append_tail(lead, self.text, *tail)
    p lead, self.text, tail

    self.text = +"e"
    keyword_tail = [+"f"]
    append_keyword(lead, self.text, *keyword_tail, suffix: "!")
    p lead, self.text, keyword_tail

    self.text = +"g"
    last = +"h"
    append_rest(self.text, *[last])
    p self.text, last

    # A post takes the reader before an empty splat; a nonempty splat can
    # instead leave the reader in the rest, even after another rest source.
    self.text = +"a"
    append_post(self.text, *[])
    p self.text
    self.text = +"a"
    last = +"b"
    append_post(self.text, *[last])
    p self.text, last
    self.text = +"a"
    first = +"x"
    append_post(first, self.text, *[])
    p first, self.text
    self.text = +"a"
    first = +"x"
    last = +"b"
    append_post(first, self.text, *[last])
    p first, self.text, last

    self.text = "frozen"
    frozen_tail = [+"unchanged"]
    begin
      append_rest(self.text, *frozen_tail)
    rescue => e
      p e.class
    end
    p self.text, frozen_tail
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

# Ordinary local arguments before splats already carry their handles.
def append_rest_top(*r) = r.each { |e| e << "!" }
def append_tail_top(a, *r) = r.each { |e| e << "!" }
def append_keyword_top(a, *r, suffix:) = r.each { |e| e << suffix }

s = +"a"
items = [+"b"]
append_rest_top(s, *items)
p s, items

s = +"a"
t = +"b"
items = [+"c"]
append_tail_top(s, t, *items)
p s, t, items

s = +"a"
t = +"b"
items = [+"c"]
append_keyword_top(s, t, *items, suffix: "!")
p s, t, items

s = +"a"
t = +"b"
append_rest_top(s, *[t])
p s, t

# Posts take their arguments from the end, including a plain source before
# an empty splat. A nonempty splat can leave that same source in the rest.
def append_post_fresh(*rest, last) = (rest.each { |e| e << "!" }; last << "?")
s = +"a"
append_post_fresh(s, *[])
p s
s = +"a"
append_post_fresh(s, *[+"b"])
p s
s = +"a"
append_post_fresh(+"x", s, *[])
p s
s = +"a"
x = +"x"
b = +"b"
append_post_fresh(x, s, *[b])
p x, s, b

def append_lead_post_fresh(lead, *rest, last) = (rest.each { |e| e << "!" }; last << "?")
lead = +"lead"
s = +"a"
append_lead_post_fresh(lead, s, *([]))
p lead, s
s = +"a"
x = +"x"
append_lead_post_fresh(lead, x, s, *[])
p lead, x, s

# The same placement holds when the rest escapes as the call's result.
def append_post_kept(*rest, last) = (rest.each { |e| e << "!" }; last << "?"; rest)
r.text = +"reader"
p append_post_kept(r.text, *[])
p r.text
r.text = +"reader"
last = +"last"
p append_post_kept(+"first", r.text, *[last])
p r.text, last
