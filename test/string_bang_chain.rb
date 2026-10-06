# A String bang called on another bang's result (`s.upcase!.downcase!`)
# mutates the one String both act on. The outer bang read its receiver
# twice, once for the frozen check and once for the transform, so the
# inner bang ran again, changed nothing and answered nil: the chain raised
# NoMethodError on nil, and a receiver with a side effect (`gets.chomp!`)
# ran it twice. The outer bang's result also never reached the variable the
# chain starts from. A chain whose inner bang answers nil raises
# NoMethodError naming the outer bang.

s = +"Ab"
p s.upcase!.downcase!
p s

t = +"  hi  "
p t.strip!.upcase!
p t

u = +"aaBB"
p u.squeeze!.swapcase!
p u

v = +"hello world"
p v.sub!("o", "0").gsub!("l", "L")
p v

w = +"abc"
p w.capitalize!.reverse!
p w

y = +"zz"
p y.succ!.next!
p y

q = +"abc"
p q.tr!("a", "b").delete!("b")
p q

k = +"abc"
p k.upcase!.downcase!.capitalize!.swapcase!
p k

# a block form, whose loop runs ahead of the statement
a = +"hello"
p a.upcase!.gsub!(/L/) { |m| m.downcase }
p a

# the in-place mutators on a bang's result
b = +"x  y"
p b.squeeze!.concat("!")
p b
c = +"ab"
p((c.upcase! << "c"))
p c
d = +"ab"
p d.upcase!.replace("zz")
p d
e = +"ab"
p e.upcase!.insert(1, "-")
p e

# statement form, an ivar, a global, a parameter, a boxed variable
x = +"Hello"
x.upcase!.downcase!
p x

class Box
  def initialize = (@v = +" Hi ")

  def run
    p @v.strip!.swapcase!
    p @v
  end
end
Box.new.run

$g = +"abc"
p $g.upcase!.reverse!
p $g

def m(x)
  x.upcase!.downcase!
  x
end
p m(+"Qq")

bx = ARGV.size > 5 ? 1 : +"Ab"
p bx.upcase!.insert(1, "-")
p bx

# safe navigation stops at the nil
f = +"ab"
p f.strip!&.upcase!
p f

# the inner bang changes nothing: NoMethodError for the outer one
n = +"AB"
begin
  n.upcase!.downcase!
rescue NoMethodError => ex
  p ex.message
end
p n
begin
  p n.strip!.upcase!
rescue NoMethodError => ex
  p ex.message
end
begin
  n.sub!("z", "y").gsub!(/A/) { |mm| mm * 2 }
rescue NoMethodError => ex
  p ex.message
end

# an option and an ignored block on the outer link
g = +"Ab"
p g.upcase!.downcase!(:fold) { 0 }
p g
h = +"aB"
p h.swapcase!.capitalize! { break 0 }
p h

# a receiver with a side effect runs once
$n = 0
def fresh
  $n += 1
  +"v#{$n}"
end
p fresh.upcase!
p fresh.sub!("v", "w").upcase!
p $n
