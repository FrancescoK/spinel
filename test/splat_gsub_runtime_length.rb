# `s.gsub(*a)` / `sub` / their bangs where a's length is only known at run
# time, with and without a block. One element is the pattern alone: an
# Enumerator of the matches without a block, the block's replacement with
# one. The dispatch took gsub as two arguments only, and refused a block
# altogether, so these raised ArgumentError or passed the array itself as
# the pattern.
def args(n) = [/b/, "X"].first(n)
def sargs(n) = ["b", "X"].first(n)

s = "abcb"
p s.gsub(*args(2))
p s.gsub(*args(1)).to_a
p s.gsub(*sargs(1)).to_a
p s.gsub(*args(1)) { |m| m.upcase }
p s.gsub(*sargs(1)) { |m| m.upcase + "!" }
p s.gsub(*args(2)) { "ignored" }
p s.sub(*args(1)) { |m| "<#{m}>" }
p s.sub(*args(2))

t = "abcb".dup
t.gsub!(*args(1)) { "Y" }
p t
u = "abcb".dup
u.sub!(*sargs(1)) { |m| m * 3 }
p u
v = "abcb".dup
v.gsub!(*args(2))
p v

[0, 3].each do |n|
  begin
    s.gsub(*[/b/, "X", "Z"].first(n))
  rescue ArgumentError => e
    p e.message
  end
end
begin
  s.sub(*args(1))
rescue ArgumentError => e
  p e.message
end

# a pattern that is a Regexp or a String only at run time, with a block
[/b/, "c"].each do |pat|
  p s.gsub(pat) { |m| m.upcase }
  p s.sub(pat) { |m| m.upcase }
  p s.gsub(pat).to_a
end

# gsub! with one element and no block: the Enumerator, as gsub!(re) gives it
w = "abcb".dup
e = w.gsub!(*args(1))
p e
p e.to_a
