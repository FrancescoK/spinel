# In-place String mutators on a poly (boxed) receiver change the one string
# object, so every other reference to it sees the change.

x = ARGV.empty? ? "hello world".dup : [1]
y = x
p x.replace("zz")
p x, y

x = ARGV.empty? ? "Hello".dup : [1]
y = x
x << " world"
x.concat("!")
x.prepend(">")
x.insert(1, " ")
p x, y

x = ARGV.empty? ? "Hello World".dup : [1]
y = x
p x.upcase!, y
p x.downcase!, y
p x.capitalize!, y
p x.swapcase!, y
p x.reverse!, y
p x.sub!("O", "0"), y
p x.gsub!("L", "1"), y
p x.tr!("dw", "DW"), y
p x.delete!(" "), y
p x.chop!, y
p x.slice!(0, 2), y
x[0] = "Q"
p x, y

x = ARGV.empty? ? "  aabb\n".dup : [1]
y = x
p x.chomp!, y
p x.strip!, y
p x.squeeze!, y
p x.clear, y

s = "abc".dup
x = ARGV.empty? ? s : 5
x << "d"
x.upcase!
p s, x

x = if ARGV.empty? then "abc".dup else nil end
y = x
x.replace("q") if x
p x, y

class Holder
  def initialize
    @v = ARGV.empty? ? "abc".dup : [1]
  end

  def go
    alias_ref = @v
    @v.replace("zz")
    @v << "!"
    p @v, alias_ref
  end
end
Holder.new.go

def fill_in(v) = v.replace("filled")
x = ARGV.empty? ? "abc".dup : [1]
y = x
fill_in(x)
p x, y

z = ARGV.empty? ? [3, 1, 2] : "AB"
w = z
p z.shuffle!.size
p z.sort, w.sort
z.sort!
p z.map! { |v| v * 2 }, w

$pg = ARGV.empty? ? "abc".dup : [1]
gy = $pg
$pg.replace("zz")
$pg << "!"
p $pg, gy

h = {k: ARGV.empty? ? "abc".dup : [1]}
e = h[:k]
h[:k].replace("q")
p h, e

source = ARGV.empty? ? "abc".dup : [1]
target = source
target.replace("src")
p source, target

n = ARGV.size + 1
x = case n when 1 then "abc".dup else [1] end
y = x
x.replace("when")
p x, y

x = case n
    in 1 then "abc".dup
    else [1]
    end
y = x
x.replace("in")
p x, y

class Changer
  def change(v) = v.replace("changed")
end
x = ARGV.empty? ? "abc".dup : [1]
y = x
Changer.new.change(x)
p x, y

def mutate(v) = v.replace("mutated")

class IvarArg
  def initialize
    @v = ARGV.empty? ? "abc".dup : [1]
  end

  def go
    alias_ref = @v
    mutate(@v)
    p @v, alias_ref
  end
end
IvarArg.new.go

$ga = ARGV.empty? ? "abc".dup : [1]
gy = $ga
mutate($ga)
p $ga, gy
