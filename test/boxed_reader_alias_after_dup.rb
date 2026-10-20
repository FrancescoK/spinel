# A String read through a reader on a receiver of several classes, aliased,
# then re-pointed to a copy while both names are mutated: `x = b.s; y = x;
# x = x.dup; x << "!"; y << "?"` changes the member through y alone. The
# readers are `def s = @s` of one class and a method answering a new String
# of another; the read was refused ("this String is shared with another name,
# and the route does not carry the shared handle yet") because the route's
# carry was decided before the readers' slots settled, and the plan's check
# of a dispatch whose arms answer a new String beside a published handle
# disagreed with the one the emitter uses (strbuf_poly_user_boxes).
# The alias is written bare, in parentheses, under a sequence of statements
# and as the last of an array.
class Box
  def initialize; @s = +"abc"; end
  def s = @s
end

class Other
  def s = +"zzz"
end

def bare(b)
  x = b.s
  y = x
  x = x.dup
  x << "!"
  y << "?"
  puts x, y
  puts b.s
end

def paren(b)
  x = b.s
  y = (x)
  x = x.dup
  x << "!"
  y << "?"
  puts x, y
  puts b.s
end

def seq(b)
  x = b.s
  y = (puts "side"; x)
  x = x.dup
  x << "!"
  y << "?"
  puts x, y
  puts b.s
end

def last(b)
  x = b.s
  y = [x, (puts "side"; x)].last
  x = x.dup
  x << "!"
  y << "?"
  puts x, y
  puts b.s
end

[Box, Other].each do |k|
  bare(k.new)
  paren(k.new)
  seq(k.new)
  last(k.new)
end
