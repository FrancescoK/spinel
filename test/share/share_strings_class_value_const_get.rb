# Where the program looks a constant up by name (Object.const_get), any
# class it defines can be a value: a box holding one reaches its class
# method, whose String a change through the answer shows through.
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
class C6; def self.tag(a) = ($k6 ||= +"k6"); end
p run([Object.const_get(:C6), Obj.new][ARGV.size])
p $k6
p $all
