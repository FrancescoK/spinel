# A boxed Symbol's (and Encoding's) #name answers its frozen String even
# where a class of the program defines its own name: the tag-guarded arms
# were left out with the builtin class-name arm, and the Symbol raised
# NoMethodError (actionpack's FunctionalVisitor reads `pim.name` off its
# instance_methods).
class Thing
  def name = "thing"
end

def boxed(x) = x

vals = [boxed(:visit_DOT), boxed(Thing.new), boxed(Encoding::UTF_8)]
p vals.map(&:name)
p boxed(:sym).name.frozen?

class FV
  def visit_A = 1
  def visit_B = 2
  p instance_methods(false).map { |m| m.name.delete_prefix("visit_") }.sort
end
