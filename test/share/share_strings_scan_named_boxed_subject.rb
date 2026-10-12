# A scan whose subject is a boxed value read off an Array literal that holds
# a named local (`s = [t, 1].first`) binds each match as a String of its own:
# the block keeps and changes the matches, and neither `t` nor `s` changes.
# The facts follow the subject to `t`, which the block does not name, so
# nothing can change the subject under the scan.

# the subject is an element read of a literal holding a local
t = +"abc"
s = [t, 1].first
acc = []
s.scan(/./) { |m| m << "!"; acc << m }
p acc, s, t

# printed in the block
t1 = +"ab"
s1 = [t1, 1].first
s1.scan(/./) { |m| m << "!"; p m }

# the element read is the subject itself
t2 = +"abc"
acc2 = []
[t2, 1].first.scan(/./) { |m| m << "!"; acc2 << m }
p acc2, t2

# a chain of locals, and the last element
t3 = +"abc"
u3 = t3
s3 = [1, u3].last
acc3 = []
s3.scan(/b|c/) { |m| m << "?"; acc3 << m }
p acc3, s3, t3

# the matches change after the scan, and so does t
t4 = +"ab"
s4 = [t4, 1].first
kept = []
s4.scan(/./) { |m| m << "?"; kept << m }
t4 << "c"
kept[0] << "!"
p kept, s4, t4

# inside a block
t5 = +"xy"
acc5 = []
1.times do
  s5 = [t5, 1].first
  s5.scan(/./) { |m| m << "!"; acc5 << m }
end
p acc5, t5

# the other block iterators over the same receiver
t6 = +"ab\ncd\n"
s6 = [t6, 1].first
p s6.gsub(/[a-z]/) { |m| m << "!"; m }
p s6.sub(/c/) { |m| m << "?"; m }
chars = []
s6.each_char { |m| m << "."; chars << m }
lines = []
s6.each_line { |m| m << "|"; lines << m }
p chars.size, lines, s6, t6
