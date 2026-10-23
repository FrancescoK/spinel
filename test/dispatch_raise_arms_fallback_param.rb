# The two String representations refused this program; with one it answers as CRuby.
# A boxed call whose default arm raises is new only where every method it
# can reach answers a new String: here Object's method, which the builtins
# take, answers its argument. Handed to a method that appends to it, the
# value stays refused.
class Object
  def output_content_type(src) = src
end
class Variation
  def initialize(f) = @format = f
  def output_content_type(src) = @format == "png" ? "image/png" : "application/octet-stream"
end
def keep(name, type)
  $kept = type
  type << "!" if type.frozen? == false
  name + ":" + type
end
def make(v, src) = keep("x", v.output_content_type(src))
s = +"gif"
[Variation.new("png"), 3].each { |v| p make(v, s) }
p s
