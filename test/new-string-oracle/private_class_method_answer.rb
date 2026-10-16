# private_class_method answers its receiver, the class, so a box can hold it
# and a boxed call reaches the class method that answers a String a global
# keeps. The compiler once counted the call's answer as new (#9081);
# private_class_method_answer.claims is what it claimed then, and the oracle
# must disprove it.
class Obj
  def tag(a) = +"obj"
end
def run(x)
  pr = x.tag(1)
  pr << "?"
  pr
end
class C11
  def self.tag(a) = ($k11 ||= +"k11")
  def self.helper = 1
  Me11 = private_class_method(:helper)
end
p run([C11::Me11, Obj.new][ARGV.size])
p $k11
