# A boxed receiver's call of a name no builtin has, with arguments, is a
# dispatch over the classes that define it; its default arm only raises
# NoMethodError. Where every class's method answers a new String or a
# frozen literal, the call's value is new, and a method that appends to
# its argument (unless frozen) changes only that value. A method that
# answers its parameter still hands on the argument's own String.
def keep(name, type)
  $kept = type
  type << "!" if type.frozen? == false
  name + ":" + type
end

# every answer a frozen literal
class Variation
  def initialize(f) = @format = f
  def output_content_type(src)
    Variation.ct(@format == "" ? src : @format)
  end
  def self.ct(f) = f == "png" ? "image/png" : "application/octet-stream"
end
class Blob
  def initialize(t) = @t = t
  def content_type = @t
end
def make(b, v)
  return nil if b.nil? || v.nil?
  keep("x", v.output_content_type(b.content_type))
end
vs = [Variation.new("png"), nil, 3]
p make(Blob.new(+"gif"), vs[0])
# (a frozen literal is one object: each read of it is the same)
a = vs[0].output_content_type("gif")
p keep("y", a), a.equal?(vs[0].output_content_type("jpg")), a.frozen?

# a new String in some classes; the others raise NoMethodError
class Thumb
  def initialize(f) = @format = f
  def label_for(src) = @format == "png" ? "image/png" : "x/" + src
end
class Bare; end
def label(v, src)
  keep("x", v.label_for(src))
rescue NoMethodError
  "nomethod"
end
s = +"gif"
[Thumb.new("png"), Bare.new, Thumb.new("gif"), 3].first(3).each { |v| p label(v, s) }
p s

# a superclass's method, reached through super and by a class of its own
class Shape
  def tag_for(src) = "base/" + src
end
class Square < Shape
  def initialize(f) = @format = f
  def tag_for(src) = @format == "png" ? "image/png" : super
end
class Dot < Shape; end
def tag(v, src) = keep("x", v.tag_for(src))
s2 = +"gif"
[Square.new("png"), Dot.new, Square.new("gif"), 3].first(3).each { |v| p tag(v, s2) }
p s2

# an Object method answering a new String: the builtins take it too
class Object
  def kind_for(src) = "fallback/" + src
end
class Card
  def initialize(f) = @format = f
  def kind_for(src) = @format == "png" ? "image/png" : "application/octet-stream"
end
def kind(v, src) = keep("x", v.kind_for(src))
s3 = +"gif"
[Card.new("png"), 3, "str"].each { |v| p kind(v, s3) }
p s3

# a method answering its parameter hands the argument's String on
class Pass
  def initialize(f) = @format = f
  def pick_for(src) = @format == "" ? src : "image/png"
end
def pick(v, src)
  return nil if v.nil?
  keep("x", v.pick_for(src))
end
s4 = +"gif"
p pick([Pass.new(""), nil, 3][0], s4)
p s4

# a name a builtin has: the default arm answers String#insert's receiver
class Note
  def insert(i, o) = "note-" + o
end
def bump(type)
  type << "!"
  type
end
s5 = +"held"
[Note.new, s5, 3].first(2).each { |v| p bump(v.insert(0, "a")) }
p s5

t = +"abc"
u = t
keep("y", u)
p t
