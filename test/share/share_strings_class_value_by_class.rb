# Where the program asks an object for its `class`, any class it defines can
# be a value: a box holding one reaches its class method, whose String a
# change through the answer shows through.
$all = []
b = +"buf"; $all << b; b << "!"
class Obj
  def tag(a) = +"obj"
end
def run(x)
  pr = x.tag(1)
  $all << pr
  pr << "?"
  pr
end
class C5; def self.tag(a) = ($k5 ||= +"k5"); end
p run([C5.new.class, Obj.new][ARGV.size])
p $k5
p $all
