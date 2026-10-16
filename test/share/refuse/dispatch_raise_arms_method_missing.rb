# spinel: not-cruby
# A boxed call's default arm raises NoMethodError only where no
# method_missing can answer: here a class lacking the name has the hook,
# which CRuby asks, and it answers the argument itself. The call's value
# is not new, so handing it to a method that appends to it stays refused.
class Variation
  def initialize(f) = @format = f
  def output_content_type(src) = @format == "png" ? "image/png" : "application/octet-stream"
end
class Ghost
  def method_missing(name, *args) = args[0]
  def respond_to_missing?(*) = true
end
def keep(name, type)
  $kept = type
  type << "!" if type.frozen? == false
  name + ":" + type
end
def make(v, src) = keep("x", v.output_content_type(src))
vs = [Variation.new("png"), Ghost.new, 3]
s = +"gif"
p make(vs[0], s)
p make(vs[1], s)
p s
