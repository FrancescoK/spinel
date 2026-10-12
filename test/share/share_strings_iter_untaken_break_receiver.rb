# A String iterator given a block answers its receiver when no break is
# taken. Where the receiver holds the shared handle (or a box of it), that
# answer is the receiver itself, so a change through it reaches every name
# of the receiver, as CRuby's one object does.

s = +"ab"
x = s.scan(/./) { |m| break m if m == "z" }
x << "!"
p x, s

s1 = +""
x1 = s1.scan(/./) { |m| m << "?"; break m }
x1 << "!"
p x1, s1

s2 = +"ab"
x2 = s2.each_char { |ch| break ch if ch == "z" }
x2 << "!"
p x2, s2

s3 = +"a\nb\n"
x3 = s3.each_line { |l| break l if l == "z" }
x3 << "!"
p x3, s3

s4 = +"ab"
x4 = s4.each_byte { |b| break b if b == 0 }
x4 << "!"
p x4, s4

s5 = +"ab"
x5 = s5.tap { |v| break v if v == "z" }
x5 << "!"
p x5, s5

# a boxed receiver with another name
t6 = +"ab"
s6 = [t6, 1].first
x6 = s6.scan(/./) { |m| m << "!"; break m if m == "z!" }
x6 << "?"
p x6, s6, t6

# an instance variable receiver
class EachIvar
  def initialize; @s = +"ab"; end
  def go
    x = @s.each_char { |ch| break ch if ch == "z" }
    x << "!"
    @s
  end
end
p EachIvar.new.go

# the break taken: its value, the receiver untouched
s7 = +"ab"
x7 = s7.scan(/./) { |m| break m if m == "b" }
x7 << "!"
p x7, s7

# a bang method answers nil when it changes nothing
s8 = +"ab"
x8 = s8.gsub!(/z/) { |m| break m if m == "q"; m }
p x8, s8
