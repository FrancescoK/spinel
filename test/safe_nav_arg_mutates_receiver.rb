# A safe-navigation call tests its receiver for nil first, then runs its
# arguments, and the call sees the String those arguments changed in place:
# the receiver is the same object throughout. An argument that assigns the
# receiver's variable leaves the call on the String it had, and so does
# code of the program's that the arguments run (a setter, a to_s, a ===, an
# ==, a <=>, instance_variable_set), which can assign the variable with no
# assignment in sight.

t = +"ab"
p t&.center((t << "!"; 7))
a = +"ab"
p a&.ljust((a.upcase!; 6))
b = +"ab"
p b&.center((b.replace("xyz"); 7))
w = +"ef"
p w&.center(8, (w << "*"; "-"))
u = +"u"
out = []
3.times { |i| out << u&.ljust((u << i.to_s; 6)) }
p out

class Holder
  def initialize = @s = +"iv"
  def go = @s&.center((@s << "!"; 8))
  def keep = @s&.ljust((@s = +"new"; 9))
end
h = Holder.new
p h.go
p h.keep

$g = +"gl"
p $g&.center(($g << "g"; 8))

z = +"xy"
p z&.center((z = +"q"; 5))

# a nil receiver runs none of its arguments
$log = []
def tick(x) = ($log << x; x)
n = nil
p n&.center(tick(9))
p n&.center((n = +"x"; tick(5)))
p n, $log

# arguments that run code of the program's can reassign the receiver's
# variable with no assignment in sight: the call keeps the String it had
class Setter
  attr_accessor :s
  def initialize = @s = +"jj"
  def attr_set = @s&.center((+"t" << "x"; self.s = +"other"; 7))
  def attr_nil = @s&.center((+"t" << "x"; self.s = nil; 7))
  def ivar_set = @s&.center((+"t" << "x"; instance_variable_set(:@s, +"yy"); 8))
  def send_set = @s&.center((+"t" << "x"; send(:instance_variable_set, :@s, +"q"); 7))
  def other(o) = @s&.center((+"t" << "x"; o.s = nil; 7))
end
p Setter.new.attr_set
p Setter.new.attr_nil
p Setter.new.ivar_set
p Setter.new.send_set
st = Setter.new
p st.other(st), st.s

class Shown
  def to_s = ($g = +"new"; "o")
end
$g = +"gl"
sink = +""
shown = Shown.new
p $g&.center((sink << "x"; "#{shown}".size + 6))
p $g

class Maker
  def initialize(pr) = @pr = pr
  def to_s = (@pr.call; "o")
end
ab = +"ab"
maker = Maker.new(-> { ab = nil })
p ab&.center((sink << "x"; "#{maker}".size + 6))
p ab

class Eqq
  def ===(o) = ($g = +"new"; true)
end
$g = +"gl"
p $g&.center((sink << "x"; case 1 when Eqq.new then 7 else 9 end))
p $g

class Eq
  def ==(x) = ($g = +"new"; false)
end
$g = +"gl"
p $g&.center((sink << "x"; [Eq.new].include?(1) ? 1 : 7))
p $g

class Cmp
  include Comparable
  attr_reader :v
  def initialize(v) = @v = v
  def <=>(o) = ($g = +"new"; v <=> o.v)
end
$g = +"gl"
p $g&.center((sink << "x"; [Cmp.new(2), Cmp.new(1)].sort.size + 5))
p $g
$g = +"gl"
p $g&.center((sink << "x"; [Shown.new].join.size + 5))
p $g
